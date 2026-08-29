import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/venue_widgets.dart';

/// "How Work Fit works" — the transparency screen the 4.3(b) differentiator
/// depends on. Every claim here mirrors bamware-venue-engine's scoring.ts
/// (v2, ported from the iOS MethodologyScreen); if the formula changes there,
/// this copy changes in the same breath. No aspirational claims.
class MethodologyScreen extends StatelessWidget {
  const MethodologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.methodologyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            icon: Icons.assignment_outlined,
            title: l10n.methodologyWhatTitle,
            body: l10n.methodologyWhatBody,
          ),
          _Section(
            icon: Icons.balance_rounded,
            title: l10n.methodologyWeightsTitle,
            body: l10n.methodologyWeightsBody,
          ),
          _Section(
            icon: Icons.verified_outlined,
            title: l10n.methodologyProvenanceTitle,
            body: l10n.methodologyProvenanceBody,
          ),
          _Section(
            icon: Icons.history_rounded,
            title: l10n.methodologyDecayTitle,
            body: l10n.methodologyDecayBody,
          ),
          _Section(
            icon: Icons.help_outline_rounded,
            title: l10n.methodologyUnknownsTitle,
            body: l10n.methodologyUnknownsBody,
          ),
          const SizedBox(height: 8),
          const _TierLegend(),
          const SizedBox(height: 8),
          const _DataOrigins(),
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
  const _ScoreTier(this.labelKey, this.range, this.sampleScore);

  /// Selects the tier's localized label out of [AppLocalizations] at build
  /// time — kept as a key rather than a resolved string since this list is
  /// a top-level const built once, before any BuildContext exists.
  final String Function(AppLocalizations l10n) labelKey;
  final String range;
  final int sampleScore;
}

// Same four tiers, ranges, and colors as the discovery map's
// `_ScoreTierLegend` (work_fit_filter_menu.dart) — kept in sync by eye,
// both read from `scoreColor` in venue_widgets.dart.
const _scoreTiers = [
  _ScoreTier(_greatLabel, '75+', 80),
  _ScoreTier(_goodLabel, '60–74', 65),
  _ScoreTier(_mixedLabel, '45–59', 50),
  _ScoreTier(_weakLabel, '0–44', 20),
];

String _greatLabel(AppLocalizations l10n) => l10n.tierGreat;
String _goodLabel(AppLocalizations l10n) => l10n.tierGood;
String _mixedLabel(AppLocalizations l10n) => l10n.tierMixed;
String _weakLabel(AppLocalizations l10n) => l10n.tierWeak;

class _TierLegend extends StatelessWidget {
  const _TierLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.whatNumbersMean,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final tier in _scoreTiers) _TierRow(tier: tier, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.l10n});

  final _ScoreTier tier;
  final AppLocalizations l10n;

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
          Text(
            tier.labelKey(l10n),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.methodologyDataOriginsTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _OriginRow(
              label: l10n.methodologyOriginCuratedLabel,
              body: l10n.methodologyOriginCuratedBody,
            ),
            _OriginRow(
              label: l10n.methodologyOriginOsmLabel,
              body: l10n.methodologyOriginOsmBody,
            ),
            _OriginRow(
              label: l10n.methodologyOriginAgentLabel,
              body: l10n.methodologyOriginAgentBody,
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
