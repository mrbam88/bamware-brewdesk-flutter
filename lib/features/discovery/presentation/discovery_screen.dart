import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/core/networking/connectivity_service.dart';
import 'package:brewdesk/core/location/location_mode.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/map_marker_planner.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/core/widgets/branded_loading_view.dart';
import 'package:brewdesk/core/widgets/glass_surface.dart';
import 'package:brewdesk/features/venues/presentation/venue_widgets.dart';
import 'package:brewdesk/features/venue_detail/presentation/venue_detail_screen.dart';
import 'package:brewdesk/features/discovery/application/discovery_bloc.dart';
import 'package:brewdesk/features/discovery/application/discovery_filters_controller.dart';
import 'package:brewdesk/features/discovery/presentation/work_fit_filter_menu.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  // LEARN: the bloc is created by the widget that owns its lifetime, with
  // dependencies from the provider graph (ref.read at construction — the
  // graph is the container, the widget is just the scope). Events go in,
  // states come out; the screen never mutates anything directly.
  late final DiscoveryBloc _bloc = DiscoveryBloc(
    venueRepository: ref.read(venueRepositoryProvider),
    locationService: ref.read(effectiveLocationServiceProvider),
    connectivity: ref.read(connectivityServiceProvider),
  );
  StreamSubscription<DiscoveryState>? _blocSub;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  /// Backs the search field so map/header code can tell whether it's
  /// focused (brewdesk#28 search-focus list) without any new VM state.
  final FocusNode _searchFocus = FocusNode();

  /// Reduce-flicker floor for the branded loading state (brewdesk#33): once
  /// shown, it stays on screen at least this long, so a fast/cold-start
  /// load never flashes it for a single frame.
  static const _minBrandedLoadingDuration = Duration(milliseconds: 300);

  bool _showBrandedLoading = false;
  bool _brandedLoadingMinDurationElapsed = true;
  Timer? _brandedLoadingTimer;

  bool get _wantsBrandedLoading {
    final state = _bloc.state;
    return switch (state) {
      // Loading phases with nothing stale to show — exactly the cold-start
      // window brewdesk#33 branded. Loaded and failed always render content
      // (the shelf/empty view or a degraded card).
      DiscoveryLocating() ||
      DiscoverySearching() => state.venuesOrStale.isEmpty,
      DiscoveryLoaded() || DiscoveryFailed() => false,
    };
  }

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onFocusChanged);
    _bloc.add(const DiscoveryStarted());
    // The bloc's initial state is locating, so this reflects the real
    // initial state — assigned directly (not via setState) since the first
    // build hasn't happened yet.
    _showBrandedLoading = _wantsBrandedLoading;
    if (_showBrandedLoading) _startBrandedLoadingHold();
    // The branded-loading hold is widget-local presentation state (a timer
    // + two booleans), so it stays in the State class and just follows the
    // bloc's stream.
    _blocSub = _bloc.stream.listen((_) => _syncBrandedLoading());
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    _searchController.dispose();
    _blocSub?.cancel();
    _brandedLoadingTimer?.cancel();
    _bloc.close();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  /// Keeps [_showBrandedLoading] in sync with the model, holding it visible
  /// for [_minBrandedLoadingDuration] once shown — see the class doc above.
  void _syncBrandedLoading() {
    final wants = _wantsBrandedLoading;
    if (wants == _showBrandedLoading) return;
    if (wants) {
      _startBrandedLoadingHold();
      setState(() => _showBrandedLoading = true);
    } else if (_brandedLoadingMinDurationElapsed) {
      setState(() => _showBrandedLoading = false);
    }
    // else: still within the minimum-display window — the pending timer
    // started by [_startBrandedLoadingHold] turns it off once the floor
    // elapses (if the model still doesn't want it shown by then).
  }

  /// Arms the reduce-flicker floor: [_brandedLoadingMinDurationElapsed]
  /// flips true no sooner than [_minBrandedLoadingDuration] after the
  /// branded loading state appears, whether that's the very first frame
  /// (called directly from [initState]) or a later reappearance (called
  /// from [_syncBrandedLoading]).
  void _startBrandedLoadingHold() {
    _brandedLoadingMinDurationElapsed = false;
    _brandedLoadingTimer?.cancel();
    _brandedLoadingTimer = Timer(_minBrandedLoadingDuration, () {
      _brandedLoadingMinDurationElapsed = true;
      if (mounted && !_wantsBrandedLoading) {
        setState(() => _showBrandedLoading = false);
      }
    });
  }

  void _cancelSearch() {
    _searchController.clear();
    ref.read(discoveryFiltersControllerProvider.notifier).setQuery('');
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // LEARN: the BlocListener/BlocBuilder split is rendering vs side
    // effects. The listener runs ONCE per matching transition and may do
    // imperative things (here: fly the map camera); the builder must stay
    // a pure state->widgets function that can run any number of times.
    // Navigation and snackbars belong in listeners for the same reason.
    return BlocListener<DiscoveryBloc, DiscoveryState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          current.centerOrNull != null &&
          previous.centerOrNull != current.centerOrNull,
      listener: (context, state) =>
          _mapController.move(state.centerOrNull!, 13.5),
      child: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        bloc: _bloc,
        builder: (context, state) {
          // LEARN: server state (the bloc's venues) meets client state
          // (query + filters, from the Notifier) HERE, in the widget — a
          // pure function applied at render time, like deriving a filtered
          // list in a selector instead of storing it.
          final venues = ref
              .watch(discoveryFiltersControllerProvider)
              .apply(state.venuesOrStale);
          final searching = _searchFocus.hasFocus;
          return Scaffold(
            body: searching
                ? _searchFocusView(l10n, venues, state)
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              state.centerOrNull ?? DiscoveryBloc.manhattan,
                          initialZoom: 13.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'io.bamware.brewdesk',
                          ),
                          MarkerLayer(
                            markers: MapMarkerPlanner.plan(venues)
                                .map(
                                  (venue) => Marker(
                                    point: LatLng(venue.lat, venue.lng),
                                    width: 40,
                                    height: 40,
                                    child: _MapPin(
                                      venue: venue,
                                      onTap: () => _openVenue(venue),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                              ),
                            ],
                          ),
                        ],
                      ),
                      SafeArea(
                        child: _searchAndFilters(
                          context,
                          l10n,
                          venues.length,
                          state.venuesOrStale.length,
                          state,
                        ),
                      ),
                      // LEARN: `case` on the sealed state — the failure card
                      // can only be built from a DiscoveryFailed, and the
                      // failure's TYPE picks the key/copy. No booleans to
                      // cross-check, no error text without an error.
                      if (state case DiscoveryFailed(:final failure))
                        Center(
                          child: _ErrorCard(
                            key: Key(switch (failure) {
                              DiscoveryOffline() => 'discovery-state-offline',
                              DiscoveryEngineDown() =>
                                'discovery-state-engine-error',
                            }),
                            message: switch (failure) {
                              DiscoveryOffline() => l10n.discoveryErrorOffline,
                              DiscoveryEngineDown(:final message?) => message,
                              DiscoveryEngineDown() =>
                                l10n.discoveryErrorGeneric,
                            },
                            failure: failure,
                            onRetry: () =>
                                _bloc.add(const DiscoveryRetryPressed()),
                          ),
                        )
                      else if (_showBrandedLoading)
                        const Positioned.fill(
                          child: BrandedLoadingView(
                            key: Key('discovery-state-loading'),
                          ),
                        )
                      else
                        _venueShelf(l10n, venues),
                    ],
                  ),
            floatingActionButton: searching
                ? null
                : Padding(
                    padding: const EdgeInsets.only(bottom: 232),
                    child: FloatingActionButton.small(
                      tooltip: l10n.discoveryUseMyLocationTooltip,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: AppColors.green,
                      // LEARN: widgets ADD EVENTS; they never await work or
                      // move the camera themselves — the BlocListener above
                      // owns that side effect, for taps and auto-retries
                      // alike. restartable() makes mashing this safe.
                      onPressed: () => _bloc.add(const DiscoveryStarted()),
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// UI3 search-focus mode (brewdesk#28, mockup 02): the map gives way to a
  /// vertical result list. `Scaffold.resizeToAvoidBottomInset` (the default)
  /// already shrinks this column above the keyboard — no manual inset math
  /// needed.
  Widget _searchFocusView(
    AppLocalizations l10n,
    List<Venue> venues,
    DiscoveryState state,
  ) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: _searchAndFilters(
            context,
            l10n,
            venues.length,
            state.venuesOrStale.length,
            state,
          ),
        ),
        Expanded(
          child: venues.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.discoveryEmptyView,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  key: const Key('search-results-list'),
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    return VenueCard(
                      venue: venue,
                      // LEARN: watch (not read) — a save from anywhere, this
                      // screen included, rebuilds just this subtree. This
                      // replaces a blank setState listener that redrew the
                      // whole screen on every toggle.
                      saved: ref
                          .watch(savedVenueIdsProvider)
                          .contains(venue.id),
                      onTap: () => _openVenue(venue),
                      onSave: () => ref
                          .read(savedVenueIdsProvider.notifier)
                          .toggle(venue.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// One header card (ui-review parity with iOS `CafeMapScreen.searchHeader`):
  /// search field + trailing control (filter button, or Cancel while
  /// focused) on top, an in-card count row underneath. The baseline banner
  /// docks directly beneath the card as a sibling row.
  Widget _searchAndFilters(
    BuildContext context,
    AppLocalizations l10n,
    int visibleCount,
    int totalCount,
    DiscoveryState state,
  ) {
    final theme = Theme.of(context);
    final searching = _searchFocus.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 16),
              ],
            ),
            child: GlassSurface(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              onChanged: ref
                                  .read(
                                    discoveryFiltersControllerProvider.notifier,
                                  )
                                  .setQuery,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: l10n.discoverySearchHint,
                                prefixIcon: const Icon(Icons.search_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (searching)
                            TextButton(
                              key: const Key('search-cancel'),
                              onPressed: _cancelSearch,
                              child: Text(l10n.cancel),
                            )
                          else
                            const WorkFitFilterButton(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.discoveryVisibleOfTotal(
                                visibleCount,
                                totalCount,
                              ),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            l10n.discoveryScoresShowWorkFit,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state case DiscoveryLoaded(coverage: CoverageLevel.baseline))
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.discoveryBaselineBanner,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _venueShelf(AppLocalizations l10n, List<Venue> venues) {
    return DraggableScrollableSheet(
      // Sizes account for extendBody (#30): the sheet now runs beneath the
      // glass tab bar, so resting height rises to keep the top card visible.
      initialChildSize: 0.30,
      minChildSize: 0.16,
      maxChildSize: 0.68,
      snap: true,
      snapSizes: const [0.16, 0.30, 0.68],
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 18)],
          ),
          child: GlassSurface(
            opacity: 0.82,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            child: venues.isEmpty
                ? ListView(
                    key: const Key('discovery-state-empty'),
                    controller: controller,
                    children: [
                      const SizedBox(height: 12),
                      _ShelfHandle(l10n: l10n, count: venues.length),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.discoveryEmptyView,
                              textAlign: TextAlign.center,
                            ),
                            if (ref
                                    .watch(discoveryFiltersControllerProvider)
                                    .activeCount >
                                0) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                key: const Key('discovery-clear-filters'),
                                onPressed: ref
                                    .read(
                                      discoveryFiltersControllerProvider
                                          .notifier,
                                    )
                                    .resetFilters,
                                child: Text(l10n.discoveryClearFilters),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: controller,
                    itemCount: venues.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ShelfHandle(l10n: l10n, count: venues.length);
                      }
                      final venue = venues[index - 1];
                      return VenueCard(
                        venue: venue,
                        saved: ref
                            .watch(savedVenueIdsProvider)
                            .contains(venue.id),
                        onTap: () => _openVenue(venue),
                        onSave: () => ref
                            .read(savedVenueIdsProvider.notifier)
                            .toggle(venue.id),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _openVenue(Venue venue) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => VenueDetailScreen(initialVenue: venue)),
    );
  }
}

/// Circular ~40dp badge: tier color fill, 2dp white ring, centered bold
/// score (mockup 01 / iOS `MapAnnotationViews.VenueScorePin`).
class _MapPin extends StatelessWidget {
  const _MapPin({required this.venue, required this.onTap});
  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scoreColor(venue.workScore),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            venue.workScore.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shelf header: "N spots in view" left, "drag for map" hint right (mockup
/// 01) — replaces the old centered "Best nearby" title.
class _ShelfHandle extends StatelessWidget {
  const _ShelfHandle({required this.l10n, required this.count});

  final AppLocalizations l10n;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 9),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.discoveryShelfSpotsInView(count),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                l10n.discoveryDragForMapHint,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    super.key,
    required this.message,
    required this.failure,
    required this.onRetry,
  });
  final String message;
  final DiscoveryFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(28),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(switch (failure) {
              DiscoveryOffline() => Icons.wifi_off_rounded,
              DiscoveryEngineDown() => Icons.cloud_off_rounded,
            }, size: 34),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.discoveryTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
