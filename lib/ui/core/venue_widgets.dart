import 'package:flutter/material.dart';

import '../../domain/models/venue.dart';
import 'app_theme.dart';

Color scoreColor(int score) {
  if (score >= 75) return AppColors.green;
  if (score >= 60) return AppColors.scoreGood;
  if (score >= 45) return AppColors.scoreMixed;
  return const Color(0xFF9B5A52);
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
        '$score',
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
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _typeIcon(venue.venueType),
                  color: theme.colorScheme.primary,
                ),
              ),
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
                    const SizedBox(height: 4),
                    Text(
                      '${venue.typeLabel} · ${venue.distanceLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_claim(venue.attributes.wifi, 'Wi-Fi')} · ${_claim(venue.attributes.seating, 'seating')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: venue.workScore, compact: true),
              IconButton(
                tooltip: saved ? 'Remove from saved' : 'Save spot',
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

  static String _claim(Claim claim, String label) =>
      claim.value == 'unknown' ? '$label unknown' : claim.displayValue;

  static IconData _typeIcon(String type) => switch (type) {
    'park' => Icons.park_outlined,
    'library' => Icons.local_library_outlined,
    'mall' => Icons.store_mall_directory_outlined,
    _ => Icons.local_cafe_outlined,
  };
}
