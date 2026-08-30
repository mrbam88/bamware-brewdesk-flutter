# State-Management Architecture Audit

_Phase 0 of the state-architecture refactor (2026-08-30). Read-only findings;
the target design lives in `docs/adr/0001-state-management.md`._

> **Outcome (post-refactor):** every finding below was addressed on the
> `refactor/state-architecture` branch — see the ADR for the decision and
> `docs/LEARNING_GUIDE.md` for the tour. One item was deliberately NOT
> resolved: `coldStart()` stays unwired because it conflicts with the newer
> branded-loading feature (#33) — wiring the snapshot in would make that
> state nearly unreachable. Needs a product call: wire it or delete it.

**RN translation key** (used throughout): `ChangeNotifier` ≈ a hand-rolled
Zustand store that components subscribe to; `ListenableBuilder` ≈
`useSyncExternalStore`; constructor threading ≈ prop drilling; `setState` ≈
`useState` in a class component.

## 1. Inventory — what manages state today

~6.7k LOC in `lib/`, ~3.5k LOC of tests. **Zero state-management packages** in
`pubspec.yaml` — everything is hand-rolled on Flutter primitives.

### 1a. ChangeNotifier view models (the dominant pattern)

| File | Role | Notes |
|---|---|---|
| `ui/features/discovery/discovery_view_model.dart` | search/filter/load for the Spots tab | 209 lines; loading/error/data as **three separate mutable fields** |
| `ui/features/saved/saved_view_model.dart` | hydrates saved ids → venues | manual `_generation` counter to defeat races |
| `ui/features/saved/takeout_import_view_model.dart` | Takeout import funnel | has a hand-rolled `enum TakeoutImportPhase` state machine |
| `ui/features/venue_detail/venue_detail_view_model.dart` | detail refresh + photos | swallows **all** errors silently |
| `data/repositories/saved_venues_repository.dart` | saved ids + persistence | a **repository that is also a ChangeNotifier** — data layer doubling as an event bus |

### 1b. `setState` — 14 call sites across 5 files

- `app_shell.dart` — tab index (fine; will stay local).
- `onboarding_flow.dart`, `onboarding_gate.dart` — page index + async
  bootstrap + resolved-service selection (the funnel entry).
- `discovery_screen.dart` — **the hot spot**: `_savedChanged()` and
  `_onFocusChanged()` are blank `setState(() {})` rebuild hammers; plus a
  3-field branded-loading timer machine (`_showBrandedLoading`,
  `_brandedLoadingMinDurationElapsed`, `_brandedLoadingTimer`) living inside
  a widget State.
- `venue_detail_screen.dart` — same blank-`setState` listener pattern.

### 1c. Singletons / globals / statics

- **No true mutable singletons.** DI is honest manual constructor injection
  from `main.dart` (`VenueRepository`, `SavedVenuesRepository`,
  `LocationService`) threaded through `app.dart → OnboardingGate → AppShell →
  screens` — classic prop drilling, 4 layers deep.
- `SharedPreferences.getInstance()` is called **twice** (in `main.dart` and
  again inside `OnboardingGate._bootstrap`) — a hidden service-locator lookup
  inside a widget.
- `ConnectivityService` is defaulted inline (`const ConnectivityService()`)
  in two places rather than injected from the root.
- Static *pure functions* (`TakeoutParser`, `MapMarkerPlanner`,
  `OpeningHoursParser`) are fine and stay as-is.

### 1d. Streams

- `ConnectivityService.onlineChanges` — subscribed manually in
  `DiscoveryViewModel` with hand-managed `StreamSubscription` lifecycle.
- `VenueRepository.coldStart()` — a well-tested async* stream that is
  **dead code**: no screen calls it. The bundled-snapshot cold start it
  implements never actually runs in the app.

### 1e. InheritedWidget

None (beyond framework ones). No Provider, no scoping — hence the drilling.

## 2. What's fragile (the "why refactor" evidence)

1. **The location funnel has no states.** `LocationService.currentLocation()`
   collapses *services-off, permission-denied, denied-forever, timeout, and
   any other failure* into a single `null`, and `DiscoveryViewModel.load()`
   silently substitutes Manhattan. A user who denied permission and a user
   whose GPS timed out see identical UI with no path to recovery. This is
   exactly the class of bug an explicit state machine makes unrepresentable.
2. **Loading/error/data are independent mutable fields.** In
   `DiscoveryViewModel`: `_loading`, `_error`, `_errorKind`, `_venues` can
   disagree (e.g. `loading=true` with stale venues showing). Nothing in the
   type system forces a widget to handle all three; `visibleVenues` is happily
   readable mid-error.
3. **Cross-VM sync by listener wiring.** `SavedVenuesRepository extends
   ChangeNotifier`, and `SavedViewModel`, `DiscoveryScreen`, and
   `VenueDetailScreen` each hand-subscribe (`addListener`) and must remember
   to unsubscribe. `discovery_screen.dart:100` rebuilds the *entire screen*
   on any saved change.
4. **Races handled ad hoc.** `SavedViewModel` invented a `_generation`
   counter; `DiscoveryViewModel.load()` has no reentrancy guard at all — two
   overlapping loads interleave their field writes.
5. **Errors swallowed.** `VenueDetailViewModel.load()` catches `Object` and
   does nothing — a failed refresh is indistinguishable from a fast success.
6. **UI copy in the data layer.** `bundledSnapshotNote` is a hard-coded
   English string inside `venue_repository.dart` (l10n bypass) — moot today
   only because `coldStart()` is dead code.
7. **Widget-resident state machines.** The branded-loading minimum-display
   logic (timer + 2 booleans in `_DiscoveryScreenState`) and the
   `OnboardingGate` bootstrap are business logic that can only be tested by
   pumping widgets.
8. **In-memory venue cache is unbounded and invisible** (`Map<String,Venue>`
   in `VenueRepository`) — fine at this scale, but uninspectable and untyped
   as a caching policy (no TTL, no invalidation story).

**What's already good** (keep, don't churn): repositories exist as a layer;
constructor injection everywhere (no service locator); pure domain helpers
with strong tests; `VenueScenario` fixture seam; typed
`VenueOfflineException` vs `VenueApiException`; 28 test files.

## 3. Current pattern → target pattern

| Feature / concern | Today | Target |
|---|---|---|
| DI (repos, services) | constructor drilling from `main.dart` | Riverpod `Provider`s at the root; widgets `ref.watch` what they need (RN: Context+hooks replacing prop drilling) |
| Discovery: venue search | `ChangeNotifier` with 4 loose fields | **flagship Bloc** — see §4 |
| Discovery: location funnel | `LatLng?` + silent Manhattan fallback | flagship Bloc states + typed `LocationFailure` taxonomy |
| Discovery: offline auto-retry | manual `StreamSubscription` in VM | Bloc event stream (`_ConnectivityRestored` event) |
| Discovery: search query + filters | same ChangeNotifier | plain `Notifier` provider (client state ≠ server state; RN: the Zustand-vs-TanStack split) |
| Venue detail (per-venue) | `ChangeNotifier`, errors swallowed | `AsyncNotifier.family(venueId)` with `autoDispose`; `AsyncValue` forces loading/error/data handling (RN: TanStack `useQuery(['venue', id])`) |
| Saved ids | `ChangeNotifier` repository | repo behind an interface + `Notifier<Set<String>>` provider; screens watch the provider, not the repo |
| Saved list hydration | `_generation` counter | `AsyncNotifier` — Riverpod rebuild semantics replace the counter |
| Takeout import | `ChangeNotifier` + phase enum | keep the enum shape, move to a `Notifier` (already a decent little machine; low churn) |
| Onboarding gate/bootstrap | `setState` + double `SharedPreferences.getInstance()` | `FutureProvider` for prefs + small `Notifier` for flow step |
| Branded-loading hold | timer machine in widget State | derived from Bloc state + one tiny presentation `Notifier` |
| Tab index, page index | `setState` | **stays `setState`** — deliberately (the lesson: local ephemeral UI state is fine where it is) |
| `coldStart()` dead code | dead | either wired into the flagship Bloc as the cold-start path or deleted — decide in Phase 3 (recommend: wire it in; it's built and tested) |

## 4. Flagship Bloc nomination: the Discovery funnel

**Nominee:** location-permission → acquiring-location → searching →
results / empty / degraded (engine-down vs offline, with auto-retry) — i.e.
`DiscoveryViewModel.load()` plus the `LocationService` null-collapse plus the
connectivity resubscribe logic, modeled as one sealed-state machine.

**Why this one and not the alternatives:**

- It is the app's spine — every session runs this funnel; it's BrewDesk's
  IoT-pairing-funnel equivalent, with OS permissions, hardware (GPS),
  network, and server health all able to fail differently.
- It has the richest *real* error taxonomy already half-present in the code
  (`VenueOfflineException`, `VenueApiException`, `CoverageLevel`, timeout
  nulls) — the Bloc makes explicit what today is folklore.
- It has genuine concurrency: overlapping loads (needs `restartable`),
  retry-button spam (needs `droppable`), and an autonomous event source
  (connectivity stream) — so event transformers are load-bearing, not
  decorative.
- Runner-up considered: **Takeout import** (real phase enum today) — rejected
  as flagship because it's linear, rarely run, and has no concurrent event
  sources; it stays a plain Notifier and serves as the contrast example.
- Onboarding — too shallow (3 pages + one choice); stays lightweight.

## 5. Package additions (all listed in the brief, no extras)

`flutter_riverpod`, `riverpod_annotation` + codegen, `flutter_bloc`,
`bloc_concurrency`, `freezed` + `json_serializable` (data layer only),
`bloc_test`, `riverpod_lint`/`custom_lint`. Justifications in the ADR.
