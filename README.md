# Flutter State Management, Explained With One Real App

*This repo is BrewDesk — an Android work-café finder. It's also a complete,
running answer to the question that makes Flutter hard to keep in your head:
**where does state live?** This README is the article version of that answer.
Every claim points at a real file you can open.*

---

There's a reason Flutter state management is hard to remember: the ecosystem
teaches it as a menu of packages — setState, Provider, Riverpod, Bloc, GetX —
as if you're supposed to pick a religion. The framing that actually sticks is
different:

> **State comes in kinds. Each kind has a natural home. Architecture is
> refusing to put state in the wrong home.**

BrewDesk uses four homes, deliberately, and the whole decision fits in one
table:

| Kind of state | Example here | Home | React analogy |
|---|---|---|---|
| Ephemeral UI | selected tab | `setState` | `useState` |
| Client state | search filters | Riverpod `Notifier` | Zustand |
| Server state | saved venues, venue detail | Riverpod `AsyncNotifier` | TanStack Query |
| A state machine | the discovery funnel | one Bloc | Redux + RxJS |

If you remember nothing else, remember the table. The rest of this article is
why each row is true, using the actual code.

## Kind 1: Ephemeral state — just use setState

The bottom tab bar (`lib/features/shell/presentation/app_shell.dart`) holds
its index in a `StatefulWidget` with `setState`. That's the whole
implementation, and it's correct.

The test for ephemeral state: *if this value vanished on navigation, would
anyone care? Does any other widget need it?* No and no → `setState`. Putting
a tab index in a global store is the Flutter equivalent of putting a text
field's value in Redux — a thing we all did once and regretted.

The interesting part is what *else* stayed local: the branded-loading
minimum-display timer in the discovery screen. It's a `Timer` and two
booleans of pure presentation bookkeeping. It listens to grown-up state, but
it *is not* grown-up state. Knowing what to leave out of your architecture is
half of having one.

## Kind 2: Client state — a Notifier is a tiny store

The filter menu (laptop-friendly, Wi-Fi floor, outlets, venue type, plus the
search query) is state the *user* owns: preferences about how to view data
that already loaded. It lives in one value type and one tiny store —
`lib/features/discovery/domain/discovery_filters.dart` and
`discovery_filters_controller.dart`:

```dart
@riverpod
class DiscoveryFiltersController extends _$DiscoveryFiltersController {
  @override
  DiscoveryFilters build() => const DiscoveryFilters();

  void setMinWifi(WifiLevel? value) => state = state.copyWith(minWifi: value);
  // ...four more one-line mutators
}
```

Two ideas carry all of Riverpod, and they're both visible here:

**1. State is a value you replace, never an object you mutate.**
`DiscoveryFilters` is a [freezed](https://pub.dev/packages/freezed) immutable
class; every mutator is a `copyWith`. This isn't ceremony — change detection
in Flutter (like React) is `oldState == newState`, and value types make that
comparison mean something. Mutating in place is exactly the pushing-into-a-
`useState`-array bug, and immutability makes it unrepresentable.

**2. `ref.watch` in build, `ref.read` in callbacks.** Watch = subscribe
("rebuild me when this changes"); read = grab the current value once. The
filter badge *watches* the filter count; the reset button's `onPressed`
*reads* the controller to call a method. Riverpod ships a lint
(`riverpod_lint`) that enforces this mechanically — it's the
`eslint-plugin-react-hooks` of this world.

Where do filters meet the venue list? Nowhere in storage. The discovery
screen computes `filters.apply(venues)` at render time — derived data stays
derived, like a selector. The moment you *store* a filtered copy, you've
created two sources of truth and signed up to reconcile them forever.

## Interlude: the provider graph is your DI container

Before the async stuff makes sense, one structural idea. Every service and
repository in BrewDesk is exposed as a provider, declared next to its class:

```dart
@Riverpod(keepAlive: true)
VenueRepository venueRepository(Ref ref) =>
    ApiVenueRepository(ref.watch(venueApiProvider));
```

Notice the declared return type is `VenueRepository` — an **abstract
interface that lives in the domain layer**
(`lib/features/venues/domain/venue_repository.dart`). The HTTP implementation
lives in data. Consumers can't even see the concrete class. That one line is
dependency inversion, enforced.

The payoff shows up in three places:

- `main.dart` is ten lines: await SharedPreferences once, hand it to
  `ProviderScope` as an override, run the app. No hand-built object graph
  threaded through four widget layers (git history has the before-picture).
- Tests swap leaves, not wiring: `ProviderScope(overrides: [...])` is
  `jest.mock` with types.
- A fake repository is ~20 lines of pure Dart, because it implements an
  interface instead of stubbing HTTP.

## Kind 3: Server state — AsyncNotifier is your useQuery

Here's the before-picture. The old Saved screen had a hand-rolled
`ChangeNotifier` with a `_loading` flag, a venues list, a `failedIds` list, a
manual `addListener` on another notifier, and — my favorite — a
`_generation` counter to discard stale responses when two loads raced. Five
mechanisms, all hand-synchronized, all able to disagree.

The after-picture is one class
(`lib/features/saved/application/saved_spots.dart`):

```dart
@riverpod
class SavedSpotsController extends _$SavedSpotsController {
  @override
  Future<SavedSpots> build() async {
    final ids = ref.watch(savedVenueIdsProvider);   // ← the subscription
    final repository = ref.watch(venueRepositoryProvider);
    // ...hydrate ids into venues, collecting per-id failures honestly
  }
}
```

Everything the old code hand-rolled falls out of the model:

- **The race counter is gone**, not ported. `build()` re-runs when a watched
  dependency changes (a save toggles the ids), and Riverpod discards
  superseded futures automatically.
- **Loading/error/data can't desync**, because the widget receives one
  `AsyncValue<SavedSpots>` that is exactly one of the three. The screen's
  `spots.when(loading:…, error:…, data:…)` won't compile with a branch
  missing. The old screen had *no* error rendering — nothing forced anyone
  to write one. Now the compiler does.
- **Stale-while-revalidate is a flag** (`skipLoadingOnReload: true`), not an
  architecture: the list stays up while a toggle re-hydrates, exactly what
  TanStack gives you by default.

The per-venue detail screen adds the last two query concepts. Its provider
takes an argument — `build(String venueId)` — which makes it a **family**:
one independent cached instance per venue, i.e. `useQuery(['venue', id])`.
And it's **autoDispose**: cached while any screen watches it, evicted when
the last one pops. Family = query key. autoDispose = gcTime. That's the
whole cache policy, declared in the signature
(`lib/features/venue_detail/application/venue_detail_controller.dart`).

## Kind 4: When a flow is a machine, model it as one

Most features never need more than the three kinds above. Then there's the
discovery funnel — BrewDesk's spine. Resolve location (the OS permission
prompt may be up) → search → results, empty, offline, or engine-down; offline
must self-heal when connectivity returns; the retry button can be mashed; a
new "use my location" tap must cancel an in-flight load. Multiple phases, a
typed failure taxonomy, an autonomous event source, and two different race
policies. That's not a value in a store — that's a state machine, and it's
the one place this codebase uses Bloc
(`lib/features/discovery/application/discovery_bloc.dart`).

Three ideas justify the ceremony:

**Sealed states make illegal states unrepresentable.** The funnel is exactly
one of `locating / searching / loaded / failed`, each carrying only the data
that phase can have. "Loading AND errored" or "error copy without an error"
can't be constructed, and every `switch` over the funnel is
compiler-checked for exhaustiveness. The old view model held four loose
fields that could disagree; this is the same information as one value that
can't. (Failures are typed too: `offline` arms auto-retry, `engine(message)`
waits for the user. Different recovery = different *type*, not different
string.)

**Event transformers are concurrency policy you can read.** Two lines:

```dart
on<DiscoveryStarted>((e, emit) => _locateAndSearch(emit),
    transformer: restartable());   // newest intent wins — RxJS switchMap
on<DiscoveryRetryPressed>((e, emit) => _locateAndSearch(emit),
    transformer: droppable());     // mashing is ignored — exhaustMap
```

The old code's answer to "what happens when two loads overlap?" was "the
field writes interleave." Now the answer is a named policy per event, and
the connectivity-restored event flows through the same pipeline as user
taps — self-healing isn't a special case.

**One observer sees every transition.** `Bloc.observer` is set once in
`main.dart`; `AppBlocObserver` logs every `(event, from → to)` app-wide into
an analytics stub. Because state only changes through events, this is a
complete funnel trace — which location-permission exits happen, how often
offline self-heals — with zero instrumentation in feature code. This is what
Redux middleware gave you, and it's the concrete answer to "why tolerate
Bloc's ceremony": try retrofitting that onto scattered `setState`s.

One more split worth stealing even without Bloc: **builders render, listeners
do side effects.** The map camera flies via a `BlocListener` (runs once per
transition); the widget tree comes from a `BlocBuilder` (pure function of
state, runs any number of times). Navigation and snackbars belong on the
listener side, always.

## The part that makes it stick

Testability isn't a bonus here — it's the *proof* the state ended up in the
right homes:

- The filter rules test as **pure Dart functions** (no widgets, no fakes).
- Every AsyncNotifier tests with a **`ProviderContainer` and interface
  fakes** (no widget pumping).
- The Bloc tests assert **exact state sequences** — possible only because
  freezed value equality makes "expected state" a thing you can write down.
- One widget test proves a screen renders all three `AsyncValue` states —
  including the error state that didn't exist before the compiler demanded
  it.

When a piece of logic is hard to test, it's usually in the wrong row of the
table. That heuristic found every problem the refactor fixed.

*The full decision record (options considered, costs accepted) is
`docs/adr/0001-state-management.md`. A guided file-by-file tour with
interview-style Q&A is `docs/LEARNING_GUIDE.md`. The refactor itself is a
readable 13-commit story: `git log --reverse bbdbe20..27ae087`.*

---

## The app itself

BrewDesk is the Android-first Flutter client for Bamware's researched
WFH-spot finder: Google map + venue shelf, Work Fit scores with claim-level
provenance, search and workability filters, photos, directions, and
accountless on-device saves. Material 3, light + dark.

It consumes `https://venuekit-ashen.vercel.app`. The API contract is owned by
`bamware-venue-engine`; this repo is a hand-declared client
(`lib/features/venues/data/venue_dtos.dart`) and must be updated alongside
any response-shape change.

### Run

```bash
flutter pub get
flutter run          # Google Maps needs android/key.properties (mapsApiKey)
```

### Verify

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Release & store

Uploads and listing ship via fastlane (`fastlane android internal|listing`),
with all submission content — metadata, graphics, screenshots, runbooks —
under `submission/`. See `submission/README.md`.

### Notes

- `assets/venue_snapshot.json` bundles the top 50 NYC venues; refresh with
  `scripts/refresh-venue-snapshot.sh`. The cold-start path that consumes it
  is currently unwired pending a product decision (#37).
- Launcher icon and Play graphics are generated — run
  `fastlane android assets` after any brand change (see
  `submission/scripts/`).
- Visual direction: `docs/design/BrewDeskDesignSpecv1.pdf`.
