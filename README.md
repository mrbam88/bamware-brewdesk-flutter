# Flutter State Management, Explained With One Real App

I have been writing mobile apps for fifteen years, and Flutter is still the
framework I forget fastest. Not because it is conceptually harder than
UIKit or React Native, but because its state management story is usually
taught as a shopping list. Should you use setState? Provider? Riverpod?
Bloc? GetX? Every tutorial picks a favorite and shows you a counter app,
and six months later you remember none of it.

What finally made it stick for me was a different question. Instead of
asking "which package should I use," ask "what kind of state is this?"
It turns out that almost everything in a real app is one of four kinds,
and each kind has a natural home. Once you see the four kinds, the
package debate mostly evaporates.

This repo is BrewDesk, a work-café finder for Android, and it uses all
four homes on purpose. This article walks through them using the actual
code, so every claim here is something you can open and read.

| Kind of state | Example in BrewDesk | Where it lives | If you know React |
|---|---|---|---|
| Ephemeral UI state | the selected tab | `setState` | `useState` |
| Client state | search filters | a Riverpod `Notifier` | Zustand |
| Server state | saved venues, venue detail | a Riverpod `AsyncNotifier` | TanStack Query |
| A state machine | the discovery flow | one Bloc | Redux with RxJS |

## Ephemeral state: setState is not a code smell

Let's start with the kind everyone is embarrassed by. The bottom tab bar in
`lib/features/shell/presentation/app_shell.dart` keeps its selected index
in a plain `StatefulWidget` and calls `setState` when you tap a tab. There
is no provider, no store, no architecture. That is the entire
implementation, and it is the right one.

Here is the test I use. If this value disappeared when the user navigated
away, would anyone care? Does any other widget need to know about it? If
both answers are no, the state is ephemeral, and local widget state is
where it belongs. Hoisting a tab index into a global store is the Flutter
version of putting a text field's value in Redux. Most of us did that once
in 2016 and learned better.

BrewDesk keeps a second, less obvious thing local: a small timer that
holds the branded loading screen on screen for 300 milliseconds so it
never flashes. That timer watches the real state of the app, but it is
purely presentational bookkeeping, so it stays inside the widget. Deciding
what to keep *out* of your architecture is half of having one.

## Client state: a Notifier is a small store

The second kind of state appears the first time two widgets need to agree
on something. In BrewDesk that is the filter menu: laptop friendliness,
a Wi-Fi floor, an outlets floor, a venue type, and the search query. The
filter button shows a badge with the active count, the map reacts to the
selection, and the empty state offers to clear everything. Three widgets,
one truth.

This is client state. The user owns it, it describes how they want to see
data that already loaded, and nothing about it involves a network. In
BrewDesk it lives in a single immutable value plus a small Riverpod
`Notifier` that mutates it, in
`lib/features/discovery/application/discovery_filters_controller.dart`:

```dart
@riverpod
class DiscoveryFiltersController extends _$DiscoveryFiltersController {
  @override
  DiscoveryFilters build() => const DiscoveryFilters();

  void setMinWifi(WifiLevel? value) => state = state.copyWith(minWifi: value);
  // ...four more one-line mutators, and a reset
}
```

If you internalize just two ideas about Riverpod, you can reconstruct the
rest from documentation when you need it.

The first idea is that state is a value you replace, never an object you
mutate. `DiscoveryFilters` is a frozen immutable class, and every mutator
assigns a new copy through `copyWith`. This looks like ceremony until you
remember how change detection works. Flutter, like React, decides whether
anything changed by comparing the old state to the new one. If you mutate
an object in place, the comparison sees the same object and nothing
rebuilds. Immutable values make that entire class of bug impossible to
write.

The second idea is the difference between `ref.watch` and `ref.read`.
Watching means subscribing: rebuild this widget whenever the value
changes. Reading means grabbing the current value once, without
subscribing. The rule of thumb is watch in build methods, read in
callbacks. The filter badge watches the count so it repaints on every
change; the reset button reads the controller inside `onPressed` because a
button press does not need a subscription. There is a lint package,
`riverpod_lint`, that enforces this mechanically, and this repo runs it.

One more thing worth noticing: the filtered venue list is never stored
anywhere. The discovery screen computes `filters.apply(venues)` during
build, every time. Derived data should stay derived. The moment you cache
a filtered copy somewhere, you have two sources of truth and a lifelong
job keeping them in sync.

## A short detour: the provider graph is your dependency injection

Before the async material makes sense, you need one structural idea.
Every service and repository in BrewDesk is exposed to the app as a
provider, declared right next to the class it provides:

```dart
@Riverpod(keepAlive: true)
VenueRepository venueRepository(Ref ref) =>
    ApiVenueRepository(ref.watch(venueApiProvider));
```

Look closely at the types. The function's return type is
`VenueRepository`, which is an abstract interface defined in the domain
layer. The concrete class, `ApiVenueRepository`, lives in the data layer
and speaks HTTP. Because the provider's declared type is the interface,
nothing else in the app can even see the implementation. That one line is
dependency inversion, and the compiler enforces it.

This buys you three things. The app's `main` function shrinks to about
ten lines, because nobody hand-builds an object graph and threads it down
through widget constructors anymore; the git history of this repo shows
what that looked like before, and it was not pretty. Tests stop mocking
plumbing and just swap leaves, since `ProviderScope(overrides: [...])`
replaces any provider for the whole subtree underneath it, which is
`jest.mock` with types. And writing a fake repository takes about twenty
lines of plain Dart, because implementing a small interface is easy and
stubbing an HTTP client is not.

## Server state: AsyncNotifier is your useQuery

Now the kind of state that causes real production bugs. Server state is
anything fetched from a network: it is asynchronous, it can fail, it can
be stale, and two requests for it can race. This is where hand-rolled
solutions quietly fall apart.

I can show you, because this repo used to contain one. The old Saved
screen was driven by a hand-written `ChangeNotifier` holding a loading
flag, a list of venues, a list of failed IDs, and a manual listener wired
to another notifier. Its crown jewel was a `_generation` counter,
incremented on every load, so that a slow response from an old load could
be recognized and thrown away when it arrived after a newer one. Five
mechanisms, all synchronized by hand, all capable of disagreeing with
each other.

The replacement is one class in
`lib/features/saved/application/saved_spots.dart`:

```dart
@riverpod
class SavedSpotsController extends _$SavedSpotsController {
  @override
  Future<SavedSpots> build() async {
    final ids = ref.watch(savedVenueIdsProvider);
    final repository = ref.watch(venueRepositoryProvider);
    // hydrate the ids into venues, keeping per-id failures visible
  }
}
```

Notice there is no loading flag, no listener, and no generation counter,
and yet all three problems are solved. Because `build` watches the saved
IDs, every save or unsave automatically re-runs the hydration; the
subscription replaces the hand-wired listener. Because Riverpod discards
a superseded future when `build` re-runs, the race that motivated the
generation counter cannot happen; the counter was deleted, not ported.
And because the widget receives a single `AsyncValue`, which is always
exactly one of loading, error, or data, the screen's
`when(loading: ..., error: ..., data: ...)` will not compile if a branch
is missing. I want to dwell on that last one. The old screen had no error
rendering at all, not because anyone decided that, but because nothing
forced anyone to write it. Now the compiler does.

Two smaller conveniences round out the story. Passing
`skipLoadingOnReload: true` keeps the previous list on screen while a
re-hydration runs, which is the stale-while-revalidate behavior you know
from TanStack Query. And the venue detail screen shows what happens when
a provider takes an argument: `build(String venueId)` creates an
independent, individually cached instance per venue, the same idea as
`useQuery(['venue', id])`, and marking it `autoDispose` means each
instance is evicted when its last watcher goes away. A query key and a
garbage collection policy, both expressed in the method signature.

## The fourth kind: when a flow is a machine, model it as one

Most features never need more than the three kinds above, and reaching
for heavy machinery anyway is how Flutter codebases drown in boilerplate.
But BrewDesk has one flow that is genuinely different: the discovery
funnel that runs every single session.

Consider what it has to do. Resolve the device location, during which the
OS permission prompt may or may not appear, and the user may refuse.
Search the venue engine from wherever that left us. Land in one of
several outcomes: results, an empty area, "you're offline," or "the
engine is down." If offline, watch connectivity and retry by itself the
moment the network returns. Survive the user mashing the retry button,
and cancel an in-flight search if they tap "use my location" again.

That is not a value in a store. That is a state machine, with phases,
failure types, an event source that isn't the user, and two different
answers to "what happens when things overlap." It is the one place this
codebase uses Bloc, in
`lib/features/discovery/application/discovery_bloc.dart`, and three ideas
justify the ceremony.

First, sealed states. The funnel is always exactly one of `locating`,
`searching`, `loaded`, or `failed`, and each variant carries only the
data that phase can have. It is impossible to construct a state that is
loading and errored at once, or that has error text without an error,
because no such type exists. The previous implementation tracked four
independent mutable fields that could disagree; this is the same
information as one value that cannot. Failures are types too: an
`offline` failure arms the automatic retry, an `engine` failure carries
the server's message and waits for the user. When two errors recover
differently, they deserve different types, not different strings.

Second, event transformers, which are concurrency policy you can read:

```dart
on<DiscoveryStarted>((event, emit) => _locateAndSearch(emit),
    transformer: restartable());
on<DiscoveryRetryPressed>((event, emit) => _locateAndSearch(emit),
    transformer: droppable());
```

`restartable` means a new event cancels the work in progress, so the
newest intent wins; if you know RxJS, this is `switchMap`. `droppable`
means new events are ignored while one is being handled, which is what
you want for a retry button being mashed; that is `exhaustMap`. The old
code's answer to overlapping loads was that two async methods interleaved
their writes and the last one to finish won something. Now each event
declares its policy in one word, and the connectivity-restored event
flows through the same pipeline as a user's tap, so the self-healing
path is not a special case bolted on the side.

Third, the observer. `main.dart` sets `Bloc.observer` once, and from then
on every transition in the app, as an event name and a before-and-after
state, flows through a single class that forwards them to an analytics
stub. Because state can only change through events, this is a complete
trace of the funnel: how often users deny location, how often offline
heals itself, where sessions die. No analytics calls are sprinkled
through feature code. This is what Redux middleware used to give you, and
it is the honest answer to why Bloc's ceremony can be worth paying for.
Try to retrofit that trace onto a screen full of scattered `setState`
calls.

There is one more habit in this screen worth stealing even if you never
use Bloc: rendering and side effects are split. The widget tree is built
inside a `BlocBuilder`, which must stay a pure function of state, and the
map camera flies to a new position inside a `BlocListener`, which runs
once per transition. Navigation and snackbars belong on the listener
side. Mixing them into build methods is how you get a snackbar that fires
three times because the widget rebuilt three times.

## How you know the state ended up in the right place

The quiet payoff of sorting state by kind is what happens to the tests.
The filter logic tests as plain Dart functions, with no widgets and no
fakes at all. Every AsyncNotifier tests with a `ProviderContainer` and a
twenty-line fake repository, with no widget pumping. The Bloc tests
assert exact sequences of states, which is only a readable thing to write
because the states are immutable values with real equality. And one
widget test proves the Saved screen renders all three async states,
including the error state that did not exist until the type system
demanded it.

That suggests a diagnostic worth keeping. When some piece of logic is
painful to test, it is usually not a testing problem. It is state living
in the wrong row of the table.

*The decision record, including the options that lost and the costs we
accepted, is in `docs/adr/0001-state-management.md`. A file-by-file tour
with interview-style questions is in `docs/LEARNING_GUIDE.md`. The
refactor that produced all of this is thirteen commits written to be read
in order: `git log --reverse bbdbe20..27ae087`.*

---

## The app itself

BrewDesk is the Android-first Flutter client for Bamware's researched
work-spot finder: a Google map with a venue shelf, Work Fit scores with
claim-level provenance, search and workability filters, photos,
directions, and accountless on-device saves. Material 3, light and dark.

It consumes `https://venuekit-ashen.vercel.app`. The API contract is
owned by `bamware-venue-engine`; this repo is a hand-declared client
(`lib/features/venues/data/venue_dtos.dart`) and must be updated
alongside any response-shape change.

### Run

```bash
flutter pub get
flutter run    # Google Maps needs android/key.properties (mapsApiKey)
```

### Verify

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Release and store

Uploads and the Play listing ship via fastlane
(`fastlane android internal|listing`), with all submission content under
`submission/`. See `submission/README.md`.

### Notes

- `assets/venue_snapshot.json` bundles the top 50 NYC venues; refresh it
  with `scripts/refresh-venue-snapshot.sh`. The cold-start path that
  consumes it is currently unwired pending a product decision (#37).
- The launcher icon and Play graphics are generated; run
  `fastlane android assets` after any brand change.
- Visual direction: `docs/design/BrewDeskDesignSpecv1.pdf`.
