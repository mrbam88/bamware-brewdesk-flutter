# ADR 0001 — State management: Riverpod for DI + server state, one flagship Bloc

- **Status:** accepted (2026-08-30)
- **Deciders:** Bilal Malik
- **Related:** `docs/ARCHITECTURE_AUDIT.md` (the evidence base), `docs/LEARNING_GUIDE.md` (the tour)

## Context

BrewDesk Flutter reached functional completeness with no deliberate state
architecture: hand-rolled `ChangeNotifier` view models, 14 `setState` sites,
a repository that extended `ChangeNotifier` so screens could subscribe to the
data layer, and a location API whose every failure collapsed into `null`
(silently substituting Manhattan). The audit found state that could desync
(loading/error/data as independent mutable fields), hand-rolled race guards
(a `_generation` counter), and swallowed errors.

Two goals, equally weighted: make the app's state testable and legible, and
make the codebase a teaching example for Flutter state-management interviews
(reader: a 15-year iOS/RN veteran).

## Options considered

**1. setState-only.** Zero dependencies; fine for ephemeral UI state. But
server state needs caching, deduplication, error taxonomies, and testability
without widget pumping — `setState` gives none of that, and the audit showed
where that road ends. Kept only for genuinely local state (tab index, page
index, the branded-loading timer) — deliberately, as part of the lesson.

**2. Provider (the package).** InheritedWidget with ergonomics. Solves
drilling, but providers depend on the widget tree (no tree-free unit tests
of the graph), combinations (`ProxyProvider`) get stringly and verbose, and
there is no server-state story (no AsyncValue). Riverpod is its successor by
the same author, designed to fix exactly these.

**3. Riverpod everywhere (no Bloc).** Entirely workable — AsyncNotifier
covers fetching, Notifier covers client state. But the discovery funnel is a
genuine state MACHINE: five phases, a typed failure taxonomy, an autonomous
event source (connectivity), and two different concurrency policies
(restartable start vs droppable retry). Riverpod has no first-class event
vocabulary or transformer story; you would hand-roll both inside a Notifier.
Modeling that flow as data (sealed events in, sealed states out) is what
Bloc is FOR — and it makes every transition observable in one place.

**4. Bloc everywhere (no Riverpod).** The classic enterprise setup. But Bloc
for a theme toggle or a filters struct is ceremony without payoff (three
files to flip a boolean), and Bloc has no DI story — you still need
something (get_it, Provider, Riverpod) to build and hand blocs their
dependencies. Bloc-everywhere codebases are where "Flutter is boilerplate"
reputations come from.

**5. GetX.** Rejected outright: a framework-inside-the-framework (routing,
DI, state, snackbars) with global mutable singletons, magic context-free
navigation, and weak testing discipline. Its convenience is the same
convenience the audit catalogued as fragility.

## Decision

**Riverpod (3.x, codegen) is the spine:** the DI graph (every service and
repository is a provider colocated with its class, interfaces in domain,
implementations chosen by the graph), all server state (`AsyncNotifier`,
`.family` per venue id, deliberate autoDispose policies), and small client
state (`Notifier` for filters, location mode, saved ids).

**One flagship Bloc** for the discovery funnel — the app's spine and its
only true state machine — with sealed events/states, freezed value equality,
`bloc_concurrency` transformers as declared concurrency policy, and a global
`BlocObserver` feeding an analytics stub.

**Codegen (riverpod_annotation + freezed + json_serializable) is on:**
freezed already forces build_runner into the workflow, so annotation-based
providers are free, and autoDispose-by-default pushes cache policy decisions
to where they belong.

The boundary rule of thumb, for future features: ephemeral widget state →
`setState`; client/UI state → `Notifier`; anything fetched → `AsyncNotifier`
(+`.family` when keyed); a multi-phase flow with typed failures, races, or
an autonomous event source → a Bloc, and it must earn that ceremony.

## Consequences

Positive:
- Loading/error/data cannot desync (AsyncValue; sealed states); errors
  cannot be silently swallowed (the compiler demands the error branch).
- Application and domain logic test as pure Dart: ProviderContainer with
  interface fakes, bloc_test with exact state sequences. Coverage after the
  refactor: application 92%, domain 97%.
- Every bloc transition is observable centrally (AppBlocObserver) — the
  funnel is countable without sprinkling analytics calls.
- The DI seam (interfaces in domain, providers choose implementations) makes
  fakes ~20 lines and swaps (a synced saved-venues backend) non-events.

Negative / accepted costs:
- Two paradigms in one codebase; the boundary rule above is the mitigation,
  and the contrast is deliberately part of the teaching goal.
- build_runner in the loop (`dart run build_runner build` after
  model/provider changes).
- Version reality, 2026-08: custom_lint (analyzer ≤8) cannot coexist with
  freezed 4 / riverpod_generator on analyzer ≥13, pinning us to
  riverpod 3.1 / freezed 3.2 / build_runner 2.15. Freezed 3.2.3 emits an
  illegal `final` constructor param for unmodifiable collection wrappers on
  Dart 3.13, so list-bearing freezed classes set
  `makeCollectionsUnmodifiable: false`. Revisit when custom_lint crosses
  the analyzer gap.

## Open question (parked, needs a product call)

`VenueRepository.coldStart()` — the bundled-snapshot cold start — is built
and tested but unwired. Wiring it into the flagship bloc would make the
newer branded-loading state (#33) nearly unreachable (the snapshot renders
instantly). Either wire it (snapshot wins) or delete it (branded loading
wins); the bloc keeps `search()` until that's decided.
