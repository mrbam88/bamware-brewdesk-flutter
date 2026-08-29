import 'package:flutter/material.dart';

import '../../core/venue_widgets.dart';

/// "How Work Fit works" — the transparency screen the 4.3(b) differentiator
/// depends on. Every claim here mirrors bamware-venue-engine's scoring.ts
/// (v2, ported from the iOS MethodologyScreen); if the formula changes there,
/// this copy changes in the same breath. No aspirational claims.
class MethodologyScreen extends StatelessWidget {
  const MethodologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How Work Fit works')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(
            icon: Icons.assignment_outlined,
            title: 'What we measure',
            body:
                'Five attributes per spot: laptop policy, seating, Wi-Fi, '
                'outlets, and noise — plus outdoor seating as a bonus. Every '
                'claim comes from AI web research, curated data, or a site '
                'visit.',
          ),
          _Section(
            icon: Icons.balance_rounded,
            title: 'How the score is weighted',
            body:
                'Laptop policy dominates (35%), then seating (25%), Wi-Fi '
                '(15%), outlets (15%), noise (10%); outdoor seating adds up '
                'to +5. The fastest Wi-Fi in the world is worthless where '
                'laptops are banned. Above roughly 25 Mbps, extra speed '
                'stops mattering — only genuinely slow Wi-Fi punishes hard.',
          ),
          _Section(
            icon: Icons.verified_outlined,
            title: 'Why every claim shows its source',
            body:
                'A claim moves the score in proportion to how much we '
                'believe it; the rest is anchored to a neutral prior. An '
                'unverified guess barely moves a ranking. That is why every '
                'claim shows its source, confidence, and date — and the '
                'seal appears only when a human stands behind it.',
          ),
          _Section(
            icon: Icons.history_rounded,
            title: 'Fresh beats stale',
            body:
                'Confidence halves every 90 days. A six-month-old '
                'observation is a quarter as persuasive as a fresh one — '
                'that is what keeps the dataset from quietly rotting into '
                'confident fiction.',
          ),
          _Section(
            icon: Icons.help_outline_rounded,
            title: 'Honest unknowns',
            body:
                '"Unknown" is a first-class value: we never guess. Multiple '
                'observations of one attribute combine by their median, and '
                'corroboration raises confidence — capped at 95%. We never '
                'claim certainty.',
          ),
          SizedBox(height: 8),
          _TierLegend(),
          SizedBox(height: 8),
          _DataOrigins(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTier {
  const _ScoreTier(this.label, this.range, this.sampleScore);

  final String label;
  final String range;
  final int sampleScore;
}

// Same four tiers, ranges, and colors as the discovery map's
// `_ScoreTierLegend` (work_fit_filter_menu.dart) — kept in sync by eye,
// both read from `scoreColor` in venue_widgets.dart.
const _scoreTiers = [
  _ScoreTier('great', '75+', 80),
  _ScoreTier('good', '60–74', 65),
  _ScoreTier('mixed', '45–59', 50),
  _ScoreTier('weak', '0–44', 20),
];

class _TierLegend extends StatelessWidget {
  const _TierLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What the numbers mean',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final tier in _scoreTiers) _TierRow(tier: tier),
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier});

  final _ScoreTier tier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: scoreColor(tier.sampleScore),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(tier.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(tier.range, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DataOrigins extends StatelessWidget {
  const _DataOrigins();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where the data comes from',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const _OriginRow(
              label: 'Curated',
              body: 'Entered or checked by a human.',
            ),
            const _OriginRow(
              label: 'OSM baseline',
              body:
                  'A real OpenStreetMap listing with intentionally shallow '
                  'workability data, not yet deeply researched.',
            ),
            const _OriginRow(
              label: 'Agent researched',
              body: 'Found by AI web research and labeled as an estimate.',
            ),
          ],
        ),
      ),
    );
  }
}

class _OriginRow extends StatelessWidget {
  const _OriginRow({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label — ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextSpan(text: body),
          ],
        ),
      ),
    );
  }
}
