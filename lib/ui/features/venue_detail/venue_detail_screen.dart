import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../../domain/models/venue.dart';
import '../../core/venue_widgets.dart';
import 'venue_detail_view_model.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({
    super.key,
    required this.initialVenue,
    required this.venueRepository,
    required this.savedVenues,
  });

  final Venue initialVenue;
  final VenueRepository venueRepository;
  final SavedVenuesRepository savedVenues;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  late final VenueDetailViewModel _model = VenueDetailViewModel(
    widget.initialVenue,
    widget.venueRepository,
  );
  Venue get _venue => _model.venue;
  List<VenuePhoto> get _photos => _model.photos;

  @override
  void initState() {
    super.initState();
    widget.savedVenues.addListener(_savedChanged);
    _model.load();
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
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Spot details')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _venue.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ScoreBadge(score: _venue.workScore),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_venue.typeLabel} · ${_venue.neighborhood} · ${_venue.borough}',
                      style: theme.textTheme.titleSmall,
                    ),
                    if (_venue.address case final address?) ...[
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_venue.vibeTags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: _venue.vibeTags
                            .take(5)
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (_photos.isNotEmpty) ...[
                const SizedBox(height: 18),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Image.network(
                              photo.url,
                              width: 260,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                            if (photo.attribution case final attribution?)
                              Positioned(
                                left: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    attribution,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Workability',
                icon: Icons.verified_outlined,
                children: [
                  _ClaimRow(
                    label: 'Wi-Fi',
                    icon: Icons.wifi_rounded,
                    claim: _venue.attributes.wifi,
                  ),
                  _ClaimRow(
                    label: 'Seating',
                    icon: Icons.chair_alt_outlined,
                    claim: _venue.attributes.seating,
                  ),
                  _ClaimRow(
                    label: 'Outlets',
                    icon: Icons.power_rounded,
                    claim: _venue.attributes.outlets,
                  ),
                  _ClaimRow(
                    label: 'Laptop policy',
                    icon: Icons.laptop_mac_rounded,
                    claim: _venue.attributes.laptopPolicy,
                  ),
                  _ClaimRow(
                    label: 'Noise',
                    icon: Icons.volume_down_outlined,
                    claim: _venue.attributes.noise,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'What we know',
                icon: Icons.manage_search_rounded,
                children: [
                  Text(
                    _venue.tier == 'osm-baseline'
                        ? 'This is a real OpenStreetMap listing. Workability details have not been deeply researched yet.'
                        : 'This spot combines public-source research with transparent claim-level provenance.',
                  ),
                  if (_venue.lastVerified case final date?) ...[
                    const SizedBox(height: 8),
                    Text('Updated $date', style: theme.textTheme.labelMedium),
                  ],
                  if (_venue.hoursRaw case final hours?) ...[
                    const Divider(height: 24),
                    Text(hours),
                  ],
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 14),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openDirections,
                      icon: const Icon(Icons.directions_walk_rounded),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: widget.savedVenues.contains(_venue.id)
                        ? 'Remove from saved'
                        : 'Save spot',
                    onPressed: () => widget.savedVenues.toggle(_venue.id),
                    icon: Icon(
                      widget.savedVenues.contains(_venue.id)
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    tooltip: 'Open website',
                    onPressed: _venue.website == null
                        ? null
                        : () => launchUrl(Uri.parse(_venue.website!)),
                    icon: const Icon(Icons.language_rounded),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDirections() {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${_venue.lat},${_venue.lng}',
      'travelmode': 'walking',
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({
    required this.label,
    required this.icon,
    required this.claim,
  });
  final String label;
  final IconData icon;
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                claim.displayValue,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                claim.sourceLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
