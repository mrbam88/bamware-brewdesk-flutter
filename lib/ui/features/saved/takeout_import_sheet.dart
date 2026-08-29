import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/app_theme.dart';
import 'takeout_import_view_model.dart';

/// The "N matched · M not in BrewDesk yet" result sheet shown after a
/// Takeout file has been parsed and matched. Cancel discards the result;
/// Confirm saves the matches locally.
class TakeoutImportSheet extends StatelessWidget {
  const TakeoutImportSheet({super.key, required this.model});

  final TakeoutImportViewModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final matched = model.matched;
    final unmatched = model.unmatched;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.takeoutResultSummary(matched.length, unmatched.length),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.takeoutConfirmHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (matched.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  key: const Key('import-matched-list'),
                  shrinkWrap: true,
                  children: [
                    for (final venue in matched)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bookmark_rounded,
                              size: 18,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            if (unmatched.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.takeoutNotInBrewDeskYet,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final place in unmatched)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('import-cancel'),
                    onPressed: () {
                      model.reset();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('import-confirm'),
                    onPressed: matched.isEmpty
                        ? null
                        : () async {
                            await model.confirm();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
