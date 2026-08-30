# BrewDesk state-management learning guide

A guided tour of this repo's state architecture, written for an iOS/React
Native veteran prepping Flutter state-management questions. Every claim
points at a real file in this repo; `// LEARN:` comments in those files
carry the in-context detail. The decision record is
`docs/adr/0001-state-management.md`; the before-picture is
`docs/ARCHITECTURE_AUDIT.md`. The git history of the
`refactor/state-architecture` branch is itself a lesson plan — read it
commit by commit (`git log --reverse --stat bbdbe20..`).

## The mental model in one paragraph

Riverpod is the spine: a typed object graph (DI) plus everything TanStack
Query does (server state as `AsyncValue`) plus small Zustand-style stores
(`Notifier`) for client state. On top of that, exactly one feature — the
discovery funnel — uses Bloc, because it is a real state machine: sealed
events in, sealed states out, concurrency policy declared per event,
every transition observable. Ephemeral widget state stays `setState`.
Choosing the lightest tool per state kind IS the architecture.

## Read these files, in this order

1. `lib/main.dart` — composition root: `ProviderScope`, the one async
   pre-boot override, `Bloc.observer` wired once.
2. `lib/core/di/app_providers.dart` — the throw-unless-overridden
   SharedPreferences provider (the standard async-init trick).
3. `lib/features/venues/domain/venue.dart` → `data/venue_dtos.dart` →
   `data/venue_repository.dart` — freezed domain with no JSON; DTOs as the
   anti-corruption layer; repository behind
   `domain/venue_repository.dart:15`'s interface, provider typed to the
   interface.
4. `lib/core/location/location_service.dart:35` — `LocationResult`, the
   sealed result that replaced a `Future<LatLng?>` null-collapse. The
   audit's headline fix, in miniature.
5. `lib/core/location/location_mode.dart` — a tiny `Notifier` + a derived
   provider: composition via `ref.watch` inside providers.
6. `lib/features/saved/` — the full Riverpod vertical:
   `domain/saved_venues_store.dart` (interface) →
   `application/saved_venue_ids.dart` (Notifier; immutable set updates) →
   `application/saved_spots.dart` (AsyncNotifier whose `build()` watches
   the ids — the race-counter killer) →
   `presentation/saved_screen.dart` (`AsyncValue.when`, all three states,
   `skipLoadingOnReload` at line 126).
7. `lib/features/venue_detail/application/venue_detail_controller.dart` —
   `.family` + autoDispose: `useQuery(['venue', id])` as one class.
8. `lib/features/discovery/domain/discovery_filters.dart` +
   `application/discovery_filters_controller.dart` — client state split
   from server state; a pure `apply()` testable without widgets.
9. `lib/features/discovery/application/discovery_bloc.dart` — the
   flagship. Events (:23), states (:53), failure taxonomy (:117),
   transformers (:151–:160), the connectivity subscription feeding the
   event queue.
10. `lib/features/discovery/presentation/discovery_screen.dart:147` —
    `BlocListener` (map camera side effect) vs `BlocBuilder` (pure
    render); filters meeting bloc state at render time.
11. `lib/core/observability/app_bloc_observer.dart` — the funnel you can
    see.
12. The tests, as a second tour: `discovery_bloc_test.dart` (exact
    sequences, pure-Dart fakes), `saved_spots_controller_test.dart` +
    `venue_detail_controller_test.dart` (ProviderContainer, no pumping),
    `saved_screen_async_states_test.dart` (three states on screen),
    `discovery_filters_test.dart` (logic freed from objects).

## RN → Flutter translation table

| You know | Here it is | File |
|---|---|---|
| `useState` | `setState` in a `StatefulWidget` | `app_shell.dart` (tab index — deliberately NOT a provider) |
| Context.Provider at the root | `ProviderScope` (+ overrides) | `main.dart` |
| Prop drilling → Context refactor | constructor threading → provider graph | `app.dart` (see its git history) |
| Zustand store | `Notifier` | `saved_venue_ids.dart`, `discovery_filters_controller.dart` |
| TanStack `useQuery` | `AsyncNotifier` + `AsyncValue` | `saved_spots.dart` |
| `useQuery(['venue', id])` (query keys) | `.family` provider | `venue_detail_controller.dart` |
| TanStack cache eviction / gcTime | `autoDispose` | `venue_detail_controller.dart` LEARN comment |
| stale-while-revalidate | `skipLoadingOnReload` | `saved_screen.dart:126` |
| Redux actions/reducer/store | Bloc events/handlers/state | `discovery_bloc.dart` |
| Redux middleware / devtools | `BlocObserver` | `app_bloc_observer.dart` |
| RxJS `switchMap` / `exhaustMap` | `restartable()` / `droppable()` transformers | `discovery_bloc.dart:151,:155` |
| `useEffect` for side effects on state change | `BlocListener` (and `ref.listen`) | `discovery_screen.dart:147` |
| selectors / derived state | derived providers; pure `apply()` at render | `location_mode.dart`, `discovery_screen.dart` |
| jest.mock / MSW | `ProviderScope(overrides:)` / `ProviderContainer(overrides:)` | any test in `test/` |
| TS discriminated unions + exhaustive switch | sealed classes + `switch` | `location_service.dart:35`, `discovery_bloc.dart:53` |
| Immer/RTK immutability | freezed (`copyWith`, value ==) | `venue.dart` |
| DTO/mapper layer before the store | json_serializable DTOs + `toDomain()` | `venue_dtos.dart` |

## Twelve interview questions, answered by this repo

1. **ref.watch vs ref.read?** Watch subscribes (build paths), read grabs a
   value (callbacks/init). See `discovery_screen.dart:314` — `saved:
   ref.watch(...)` rebuilds the card on toggle — vs `saved_screen.dart:41`,
   where the import model takes `ref.read` closures because callbacks need
   values, not subscriptions. Enforced mechanically by riverpod_lint.

2. **Where does server state live, and why not in widgets or a
   ChangeNotifier?** `saved_spots.dart` — its LEARN comment lists exactly
   what the deleted `SavedViewModel` hand-rolled (generation counter,
   manual listeners, three desyncable fields) that `AsyncNotifier` deletes.

3. **How do you make illegal states unrepresentable?**
   `discovery_bloc.dart:53` — one sealed state per funnel phase; "loading
   AND errored" or "error copy without an error" cannot be constructed.
   Compare the audit's finding #2 (four loose fields).

4. **How do you model errors so the UI must handle them?** Two layers:
   sealed results (`location_service.dart:35`, `DiscoveryFailure` at
   `discovery_bloc.dart:117`) make the compiler demand a branch;
   `AsyncValue.when` (`saved_screen.dart:120`) demands loading/error/data.
   The Saved screen's error branch literally did not exist pre-refactor.

5. **When is Bloc worth its ceremony?** `discovery_bloc.dart`'s class doc:
   multi-phase flow + typed failures + races + an autonomous event source
   (connectivity). Counter-example in the same repo: filters are a
   five-mutator `Notifier` (`discovery_filters_controller.dart`), and the
   Takeout import stays a screen-local ChangeNotifier on purpose.

6. **What do event transformers buy you?** `discovery_bloc.dart:151` —
   Started is `restartable` (newest wins; switchMap), RetryPressed is
   `droppable` (spam ignored; exhaustMap), chosen per event, declared in
   one line each. The audit's race findings were fixed by policy, not by
   guards.

7. **Rendering vs side effects — where does each go?**
   `discovery_screen.dart:147`: `BlocListener` flies the map camera once
   per center change; `BlocBuilder` stays a pure state→widgets function.
   Navigation/snackbars belong in listeners for the same reason.

8. **How do you test state without pumping widgets?**
   `discovery_bloc_test.dart` (bloc_test, exact freezed-state sequences, a
   20-line fake implementing the domain interface) and
   `saved_spots_controller_test.dart` (ProviderContainer + overrides).
   Value equality is what makes "expect exact states" readable.

9. **What's your caching story?** Per-venue: `.family` + autoDispose
   (`venue_detail_controller.dart:31`) — cached while watched, evicted on
   pop, refetched on re-push. Session cache in the repository
   (`venue_repository.dart`), detail refresh bypassing it deliberately.
   Saved list: `skipLoadingOnReload` for stale-while-revalidate.

10. **How does DI work without a service locator?** Interfaces in domain
    (`venue_repository.dart:15`, `saved_venues_store.dart`); providers
    colocated with implementations pick the concrete class; `main.dart`
    overrides the one async singleton. Tests swap leaves, the graph
    rebuilds itself — no `GetIt.I<...>()` anywhere.

11. **Client state vs server state — why separate?**
    `discovery_filters.dart` LEARN comment (the TanStack-vs-Zustand rule)
    and `discovery_screen.dart`'s builder, where a pure `apply()` joins
    them at render time. Splitting them let filter logic test as pure Dart
    and stopped venue loads redrawing the filter UI.

12. **A user says "my location is wrong" — walk the funnel.**
    `location_service.dart` returns a sealed reason instead of null; the
    bloc carries `locationFailure` in every state
    (`discovery_bloc.dart:53`); `app_bloc_observer.dart` logs each
    transition, so each funnel exit (services off, denied, denied forever,
    timeout) is countable in analytics. Before: all four were one silent
    Manhattan fallback (audit finding #1).

## Where each KIND of state lives (the decision table)

| State | Kind | Home |
|---|---|---|
| Selected tab, onboarding page index | ephemeral UI | `setState` |
| Branded-loading minimum-display timer | ephemeral presentation | `setState` + timer, fed by the bloc stream |
| Search query + filters | client state | `Notifier` |
| Location mode (device vs Union Square) | client state | `Notifier` + derived provider |
| Saved venue ids | client state, persisted | `Notifier` + store interface |
| Saved list hydration, venue detail | server state | `AsyncNotifier` (+`.family`) |
| The discovery funnel | state machine | the flagship Bloc |
| Takeout import | screen-local flow | ChangeNotifier (deliberate contrast) |
