import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:brewdesk/core/widgets/glass_surface.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/opening_hours_parser.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/venues/presentation/venue_widgets.dart';
import 'package:brewdesk/features/venue_detail/application/venue_detail_view_model.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  const VenueDetailScreen({
    super.key,
    required this.initialVenue,
    this.shareVenue,
  });

  final Venue initialVenue;

  /// Test seam for the Share action — defaults to the real share sheet.
  final Future<void> Function(String text)? shareVenue;

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  // LEARN: `initialVenue` stays a constructor argument — it's ROUTE data
  // (which venue this screen is about), not a service. Dependencies come
  // from the graph; identity comes from the caller. Same split as an RN
  // screen taking route params while services come from context/hooks.
  late final VenueDetailViewModel _model = VenueDetailViewModel(
    widget.initialVenue,
    ref.read(venueRepositoryProvider),
  );
  Venue get _venue => _model.venue;
  List<VenuePhoto> get _photos => _model.photos;

  /// URLs that failed to load (brewdesk#11) — tracked by URL, not index, so
  /// a stray stale entry from a prior load never mismatches. When every
  /// photo has failed, the whole strip collapses instead of sitting on
  /// screen as blank space or broken tiles.
  final Set<String> _failedPhotoUrls = {};

  bool get _photoStripVisible =>
      _photos.isNotEmpty &&
      _photos.any((photo) => !_failedPhotoUrls.contains(photo.url));

  void _markPhotoFailed(String url) {
    if (_failedPhotoUrls.add(url) && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _model.load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;
        final locale = Localizations.localeOf(context);
        return Scaffold(
          appBar: AppBar(title: Text(_venue.name)),
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
                    // The app bar already owns the name (brewdesk#28) — this
                    // card leads with the type/neighborhood line instead of
                    // repeating it.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${_venue.typeLabel} · ${_venue.neighborhood} · ${_venue.borough}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ScoreBadgeWithCaption(score: _venue.workScore),
                      ],
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
              if (_photoStripVisible) ...[
                const SizedBox(height: 18),
                SizedBox(
                  key: const Key('venue-photo-strip'),
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      if (_failedPhotoUrls.contains(photo.url)) {
                        return const SizedBox.shrink();
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Image.network(
                              photo.url,
                              width: 260,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                _markPhotoFailed(photo.url);
                                return const SizedBox.shrink();
                              },
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
                title: l10n.venueDetailWorkabilityTitle,
                icon: Icons.verified_outlined,
                subtitle: humanProvenanceLine(_cardStamp, locale),
                children: [
                  _ClaimRow(
                    label: l10n.filtersWifiTitle,
                    icon: Icons.wifi_rounded,
                    claim: _venue.attributes.wifi,
                    cardStamp: _cardStamp,
                  ),
                  _ClaimRow(
                    label: l10n.filtersOutletsTitle,
                    icon: Icons.power_rounded,
                    claim: _venue.attributes.outlets,
                    cardStamp: _cardStamp,
                  ),
                  _ClaimRow(
                    label: l10n.venueDetailClaimLaptopPolicy,
                    icon: Icons.laptop_mac_rounded,
                    claim: _venue.attributes.laptopPolicy,
                    cardStamp: _cardStamp,
                  ),
                  _ClaimRow(
                    label: l10n.venueDetailClaimNoise,
                    icon: Icons.volume_down_outlined,
                    claim: _venue.attributes.noise,
                    cardStamp: _cardStamp,
                  ),
                  // Seating is a v2 claim (venue-engine schema ve#46): a
                  // value of "unknown" means either it was never observed
                  // or explicitly reported unknown — either way, nothing to
                  // show.
                  if (_venue.attributes.seating.value != 'unknown')
                    _ClaimRow(
                      label: l10n.venueDetailClaimSeating,
                      icon: Icons.chair_alt_outlined,
                      claim: _venue.attributes.seating,
                      cardStamp: _cardStamp,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: l10n.venueDetailWhatWeKnowTitle,
                icon: Icons.manage_search_rounded,
                children: [
                  Text(
                    _venue.tier == 'osm-baseline'
                        ? l10n.venueDetailOsmDescription
                        : l10n.venueDetailResearchedDescription,
                  ),
                  if (_venue.lastVerified case final date?) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.venueDetailUpdated(humanizeDate(date, locale)),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                  if (_venue.hoursRaw case final hours?) ...[
                    const Divider(height: 24),
                    _HoursBlock(raw: hours, locale: locale),
                  ],
                  if (_venue.website case final website?) ...[
                    const Divider(height: 24),
                    InkWell(
                      onTap: () => launchUrl(Uri.parse(website)),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              website,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 14),
                ],
              ),
              child: GlassSurface(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions_walk_rounded),
                          label: Text(l10n.venueDetailDirections),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: ref.watch(savedVenueIdsProvider).contains(_venue.id)
                            ? l10n.venueDetailRemoveFromSaved
                            : l10n.venueDetailSaveSpot,
                        onPressed: () =>
                            ref.read(savedVenueIdsProvider.notifier).toggle(_venue.id),
                        icon: Icon(
                          ref.watch(savedVenueIdsProvider).contains(_venue.id)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filledTonal(
                        tooltip: l10n.venueDetailShare,
                        onPressed: _shareVenue,
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                    ],
                  ),
                ),
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

  Claim get _cardStamp => _venue.attributes.workabilityCardStamp;

  Future<void> _shareVenue() {
    final share = widget.shareVenue ?? _defaultShare;
    return share(_shareText);
  }

  String get _shareText => '${_venue.name} · $_mapsUri';

  Uri get _mapsUri => Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '${_venue.lat},${_venue.lng}',
  });

  Future<void> _defaultShare(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  /// The Workability card's one-time provenance stamp (brewdesk#119) — every
  /// other card leaves this unset.
  final String? subtitle;

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
            if (subtitle case final subtitle?) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                key: const Key('workability-provenance-stamp'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
    required this.cardStamp,
  });
  final String label;
  final IconData icon;
  final Claim claim;

  /// The Workability card's single provenance stamp (brewdesk#119). When
  /// this claim's own source/confidence/date match it exactly, the row
  /// stays quiet — the card already said it once. Only a disagreeing claim
  /// prints its own provenance line.
  final Claim cardStamp;

  bool get _agreesWithCardStamp => claim.matchesProvenance(cardStamp);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              if (!_agreesWithCardStamp)
                Text(
                  humanProvenanceLine(claim, Localizations.localeOf(context)),
                  key: const Key('claim-provenance-line'),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Business hours (brewdesk#28): structured per-rule rows when
/// [OpeningHoursParser] recognizes the string, otherwise the raw string
/// unchanged — a wrong open/closed claim is worse than no claim, so any
/// parse doubt falls back rather than guessing.
class _HoursBlock extends StatelessWidget {
  const _HoursBlock({required this.raw, required this.locale});

  final String raw;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final rows = OpeningHoursParser.parse(raw, locale);
    if (rows == null) {
      return Text(raw, key: const Key('business-hours-raw'));
    }
    return Column(
      key: const Key('business-hours-structured'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    row.dayLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(child: Text(row.timeLabel)),
              ],
            ),
          ),
      ],
    );
  }
}
