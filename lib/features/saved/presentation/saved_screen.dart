import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/features/saved/application/saved_spots.dart';
import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:brewdesk/features/saved/application/takeout_import_view_model.dart';
import 'package:brewdesk/features/saved/presentation/takeout_import_sheet.dart';
import 'package:brewdesk/features/venue_detail/presentation/venue_detail_screen.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart'
    show VenueSnapshotLoader;
import 'package:brewdesk/features/venues/presentation/venue_widgets.dart';
import 'package:brewdesk/l10n/app_localizations.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({
    super.key,
    required this.onBrowse,
    @visibleForTesting this.importPickFile,
    @visibleForTesting this.importVenuesLoader,
  });

  final VoidCallback onBrowse;

  /// Test-only seams for the Takeout import: a fake file picker and a fixed
  /// venue catalog instead of the real picker + bundled snapshot. The
  /// import model itself is always built here, wired to the real saved-ids
  /// notifier, so tests exercise the same save path production uses.
  final Future<XFile?> Function()? importPickFile;
  final VenueSnapshotLoader? importVenuesLoader;

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  // LEARN: ref.read inside callbacks — the import model asks for saved-ids
  // behavior at action time; nothing here needs to rebuild when ids change,
  // so watch would be wrong (that's the body's job below).
  late final TakeoutImportViewModel _importModel = TakeoutImportViewModel(
    isSaved: (id) => ref.read(savedVenueIdsProvider).contains(id),
    toggleSaved: (id) => ref.read(savedVenueIdsProvider.notifier).toggle(id),
    pickFile: widget.importPickFile,
    venuesLoader: widget.importVenuesLoader,
  );

  @override
  void initState() {
    super.initState();
    _importModel.addListener(_handleImportPhaseChange);
  }

  @override
  void dispose() {
    _importModel.removeListener(_handleImportPhaseChange);
    _importModel.dispose();
    super.dispose();
  }

  void _handleImportPhaseChange() {
    switch (_importModel.phase) {
      case TakeoutImportPhase.done:
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => TakeoutImportSheet(model: _importModel),
        );
      case TakeoutImportPhase.fileFailed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.savedFileReadError),
          ),
        );
        _importModel.reset();
      case TakeoutImportPhase.idle:
      case TakeoutImportPhase.working:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // LEARN: one ref.watch of an AsyncValue replaces the old ListenableBuilder
    // + ChangeNotifier pair. `when` forces this widget to render ALL THREE
    // states — loading, error, data — at compile time; the old code simply
    // had no error rendering because nothing made it write one.
    final spots = ref.watch(savedSpotsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedTitle),
        actions: [
          ListenableBuilder(
            listenable: _importModel,
            builder: (context, _) {
              final working = _importModel.phase == TakeoutImportPhase.working;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: l10n.savedImportTooltip,
                  child: TextButton.icon(
                    key: const Key('import-takeout'),
                    onPressed: working ? null : _importModel.pickAndImport,
                    icon: working
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined, size: 18),
                    label: Text(l10n.savedImportAction),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: spots.when(
        // LEARN: a saved-ids toggle re-runs the controller's build (a
        // "reload" in Riverpod terms). Without this flag the list would
        // flash back to a spinner on every save; with it, the previous list
        // stays up until the fresh one lands — the stale-while-revalidate
        // behavior TanStack gives by default.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(l10n.savedLoadError, textAlign: TextAlign.center),
          ),
        ),
        data: (data) => data.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bookmark_add_outlined,
                        size: 52,
                        color: AppColors.sage,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.savedEmptyTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.savedEmptyBody, textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: widget.onBrowse,
                        child: Text(l10n.savedBrowseNearby),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(savedSpotsControllerProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: data.venues.length + data.failedIds.length,
                  itemBuilder: (context, index) {
                    if (index < data.venues.length) {
                      final venue = data.venues[index];
                      return VenueCard(
                        venue: venue,
                        saved: true,
                        onSave: () => ref
                            .read(savedVenueIdsProvider.notifier)
                            .toggle(venue.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                VenueDetailScreen(initialVenue: venue),
                          ),
                        ),
                      );
                    }
                    final failedId =
                        data.failedIds[index - data.venues.length];
                    return _FailedSavedRow(
                      key: Key('saved-failed-$failedId'),
                      onRemove: () => ref
                          .read(savedVenueIdsProvider.notifier)
                          .toggle(failedId),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

/// One row for a saved venue id that failed to hydrate (brewdesk#11): the
/// rest of the saved list still renders around it, so a missing engine
/// record never hides the spots that did load.
class _FailedSavedRow extends StatelessWidget {
  const _FailedSavedRow({super.key, required this.onRemove});
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.savedFailedRowMessage)),
            TextButton(onPressed: onRemove, child: Text(l10n.savedRemove)),
          ],
        ),
      ),
    );
  }
}
