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

  @override
  void initState() {
    super.initState();
    widget.savedVenues.addListener(_savedChanged);
    _model.load().then((_) {
      if (mounted) _mapController.move(_model.center, 13.5);
    });
  }

  @override
  void dispose() {
    widget.savedVenues.removeListener(_savedChanged);
    _model.dispose();
    super.dispose();
  }

  void _savedChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final venues = _model.visibleVenues;
        return Scaffold(
          body: Stack(
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
                            width: 52,
                            height: 42,
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
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 116),
            child: FloatingActionButton.small(
              tooltip: l10n.discoveryUseMyLocationTooltip,
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

  Widget _searchAndFilters(
    BuildContext context,
    AppLocalizations l10n,
    int visibleCount,
    int totalCount,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Material(
            elevation: 5,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(22),
            child: TextField(
              onChanged: _model.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.discoverySearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.discoveryVisibleOfTotal(visibleCount, totalCount),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              WorkFitFilterButton(model: _model),
            ],
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
    );
  }

  Widget _venueShelf(AppLocalizations l10n, List<Venue> venues) {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.14,
      maxChildSize: 0.62,
      snap: true,
      snapSizes: const [0.14, 0.34, 0.62],
      builder: (context, controller) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
          ),
          child: venues.isEmpty
              ? ListView(
                  key: const Key('discovery-state-empty'),
                  controller: controller,
                  children: [
                    const SizedBox(height: 12),
                    _ShelfHandle(l10n: l10n),
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
                    if (index == 0) return _ShelfHandle(l10n: l10n);
                    final venue = venues[index - 1];
                    return VenueCard(
                      venue: venue,
                      saved: widget.savedVenues.contains(venue.id),
                      onTap: () => _openVenue(venue),
                      onSave: () => widget.savedVenues.toggle(venue.id),
                    );
                  },
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
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            venue.workScore.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShelfHandle extends StatelessWidget {
  const _ShelfHandle({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 7),
        Text(
          l10n.discoveryBestNearby,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
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
