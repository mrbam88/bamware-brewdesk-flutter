import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/location_service.dart';
import '../../../domain/models/venue.dart';
import '../../../domain/use_cases/map_marker_planner.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/glass_surface.dart';
import '../../core/venue_widgets.dart';
import '../venue_detail/venue_detail_screen.dart';
import 'discovery_view_model.dart';
import 'work_fit_filter_menu.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    required this.venueRepository,
    required this.savedVenues,
    required this.locationService,
    @visibleForTesting this.connectivity,
  });

  final VenueRepository venueRepository;
  final SavedVenuesRepository savedVenues;
  final LocationService locationService;

  /// Test seam for the offline→online auto-retry (brewdesk#11) — defaults to
  /// the real connectivity_plus stream.
  final ConnectivityService? connectivity;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  late final DiscoveryViewModel _model = DiscoveryViewModel(
    widget.venueRepository,
    widget.locationService,
    connectivity: widget.connectivity ?? const ConnectivityService(),
  );
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  /// Backs the search field so map/header code can tell whether it's
  /// focused (brewdesk#28 search-focus list) without any new VM state.
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.savedVenues.addListener(_savedChanged);
    _searchFocus.addListener(_onFocusChanged);
    _model.load().then((_) {
      if (mounted) _mapController.move(_model.center, 13.5);
    });
  }

  @override
  void dispose() {
    widget.savedVenues.removeListener(_savedChanged);
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _savedChanged() => setState(() {});

  void _onFocusChanged() => setState(() {});

  void _cancelSearch() {
    _searchController.clear();
    _model.setQuery('');
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final venues = _model.visibleVenues;
        final searching = _searchFocus.hasFocus;
        return Scaffold(
          body: searching
              ? _searchFocusView(l10n, venues)
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _model.center,
                        initialZoom: 13.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                    SafeArea(
                      child: _searchAndFilters(
                        context,
                        l10n,
                        venues.length,
                        _model.totalVenues,
                      ),
                    ),
                    if (_model.errorKind != null)
                      Center(
                        child: _ErrorCard(
                          key: Key(
                            _model.errorKind == DiscoveryErrorKind.offline
                                ? 'discovery-state-offline'
                                : 'discovery-state-engine-error',
                          ),
                          message:
                              _model.error ??
                              (_model.errorKind == DiscoveryErrorKind.offline
                                  ? l10n.discoveryErrorOffline
                                  : l10n.discoveryErrorGeneric),
                          kind: _model.errorKind ?? DiscoveryErrorKind.engine,
                          onRetry: _model.load,
                        ),
                      )
                    else if (_model.loading && venues.isEmpty)
                      const Center(
                        key: Key('discovery-state-loading'),
                        child: CircularProgressIndicator(),
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
                    onPressed: () async {
                      await _model.load();
                      _mapController.move(_model.center, 13.5);
                    },
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
        );
      },
    );
  }

  /// UI3 search-focus mode (brewdesk#28, mockup 02): the map gives way to a
  /// vertical result list. `Scaffold.resizeToAvoidBottomInset` (the default)
  /// already shrinks this column above the keyboard — no manual inset math
  /// needed.
  Widget _searchFocusView(AppLocalizations l10n, List<Venue> venues) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: _searchAndFilters(
            context,
            l10n,
            venues.length,
            _model.totalVenues,
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
                      saved: widget.savedVenues.contains(venue.id),
                      onTap: () => _openVenue(venue),
                      onSave: () => widget.savedVenues.toggle(venue.id),
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
                              onChanged: _model.setQuery,
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
                            WorkFitFilterButton(model: _model),
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
          if (_model.coverage == CoverageLevel.baseline)
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
                            if (_model.activeFilterCount > 0) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                key: const Key('discovery-clear-filters'),
                                onPressed: _model.resetFilters,
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
                        saved: widget.savedVenues.contains(venue.id),
                        onTap: () => _openVenue(venue),
                        onSave: () => widget.savedVenues.toggle(venue.id),
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
      MaterialPageRoute(
        builder: (_) => VenueDetailScreen(
          initialVenue: venue,
          venueRepository: widget.venueRepository,
          savedVenues: widget.savedVenues,
        ),
      ),
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
    required this.kind,
    required this.onRetry,
  });
  final String message;
  final DiscoveryErrorKind kind;
  final Future<void> Function() onRetry;

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
            Icon(
              kind == DiscoveryErrorKind.offline
                  ? Icons.wifi_off_rounded
                  : Icons.cloud_off_rounded,
              size: 34,
            ),
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
