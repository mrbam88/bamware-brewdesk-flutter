import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/core/theme/app_theme.dart';

Color scoreColor(int score) {
  if (score >= 75) return AppColors.green;
  if (score >= 60) return AppColors.scoreGood;
  if (score >= 45) return AppColors.scoreMixed;
  return const Color(0xFF9B5A52);
}

/// "Aug 1" for an ISO date string (`yyyy-MM-dd`, or a longer ISO datetime —
/// only the date part is used), in the given locale. A string that doesn't
/// parse is returned unchanged instead of guessed at.
String humanizeDate(String raw, Locale locale) {
  if (raw.isEmpty) return raw;
  final datePart = raw.length >= 10 ? raw.substring(0, 10) : raw;
  final date = DateTime.tryParse(datePart);
  if (date == null) return raw;
  return DateFormat.MMMd(locale.toString()).format(date);
}

/// The Workability card's provenance line ("Curated · 80% confidence ·
/// updated Aug 1"), with the date humanized for [locale] — mirrors
/// [Claim.provenanceLine], which stays raw/locale-free for its own tests.
String humanProvenanceLine(Claim claim, Locale locale) {
  final date = claim.dateKey.isEmpty
      ? 'an unknown date'
      : humanizeDate(claim.dateKey, locale);
  return '${claim.sourceLabel} · ${claim.confidencePercent}% confidence · '
      'updated $date';
}

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, this.compact = false});

  final int score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: scoreColor(score),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 13 : 16,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Score badge with its small "WORK FIT" caption underneath (brewdesk#28) —
/// used wherever a badge appears on its own (the venue detail hero card).
/// The venue card's left-hand tile is a separate, tier-tinted look; see
/// [_ScoreTile].
class ScoreBadgeWithCaption extends StatelessWidget {
  const ScoreBadgeWithCaption({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScoreBadge(score: score),
        const SizedBox(height: 4),
        Text(
          l10n.workFitCaptionLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Tier-tinted score tile: light tier-color background, tier-colored score
/// and "WORK FIT" caption — the venue card's left-hand tile (mockup 01,
/// iOS `DiscoveryShelfCard.venueCard`'s score tile), distinct from the solid
/// [ScoreBadge] pill used elsewhere.
class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = scoreColor(score);
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          // FittedBox: "WORK FIT" (and its es translation) must never
          // truncate to "WORK" — scale down instead of clipping.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.workFitCaptionLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    required this.saved,
    required this.onTap,
    required this.onSave,
  });

  final Venue venue;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final claimCaptions = _claimCaptions(l10n);
    final stamp = venue.attributes.workabilityCardStamp;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ScoreTile(score: venue.workScore),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      venue.neighborhood,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (claimCaptions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(spacing: 12, runSpacing: 2, children: claimCaptions),
                    ],
                    // House rule: an unknown observation date is optional
                    // data — the line is simply absent, never "unknown".
                    if (stamp.dateKey.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.venueCardProvenance(
                          humanizeDate(stamp.dateKey, locale),
                          stamp.sourceLabel,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: saved
                    ? l10n.venueDetailRemoveFromSaved
                    : l10n.venueDetailSaveSpot,
                onPressed: onSave,
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wi-Fi/Outlets caption row, wifi/outlets only, house rule: an unknown
  /// claim value contributes nothing — not even a placeholder — so the row
  /// can end up with one entry or none at all.
  List<Widget> _claimCaptions(AppLocalizations l10n) {
    final captions = <Widget>[];
    if (venue.attributes.wifi.value != 'unknown') {
      captions.add(
        _ClaimCaption(
          icon: Icons.wifi_rounded,
          label: venue.attributes.wifi.displayValue,
        ),
      );
    }
    if (venue.attributes.outlets.value != 'unknown') {
      captions.add(
        _ClaimCaption(
          icon: Icons.power_rounded,
          label: venue.attributes.outlets.displayValue,
        ),
      );
    }
    return captions;
  }
}

class _ClaimCaption extends StatelessWidget {
  const _ClaimCaption({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(label, style: style),
      ],
    );
  }
}
