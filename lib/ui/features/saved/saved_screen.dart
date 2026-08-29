import 'package:flutter/material.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../core/venue_widgets.dart';
import '../venue_detail/venue_detail_screen.dart';
import 'saved_view_model.dart';
import 'takeout_import_sheet.dart';
import 'takeout_import_view_model.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
    required this.venueRepository,
    required this.savedVenues,
    required this.onBrowse,
    @visibleForTesting this.importModel,
  });

  final VenueRepository venueRepository;
  final SavedVenuesRepository savedVenues;
  final VoidCallback onBrowse;

  /// Test-only seam: lets a widget test inject a [TakeoutImportViewModel]
  /// with a fake file picker and venue loader instead of the real ones.
  final TakeoutImportViewModel? importModel;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late final SavedViewModel _model = SavedViewModel(
    widget.venueRepository,
    widget.savedVenues,
  );
  late final bool _ownsImportModel = widget.importModel == null;
  late final TakeoutImportViewModel _importModel =
      widget.importModel ??
      TakeoutImportViewModel(savedVenues: widget.savedVenues);

  @override
  void initState() {
    super.initState();
    _model.load();
    _importModel.addListener(_handleImportPhaseChange);
  }

  @override
  void dispose() {
    _importModel.removeListener(_handleImportPhaseChange);
    if (_ownsImportModel) _importModel.dispose();
    _model.dispose();
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
          const SnackBar(content: Text("That file couldn't be read.")),
        );
        _importModel.reset();
      case TakeoutImportPhase.idle:
      case TakeoutImportPhase.working:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          actions: [
            ListenableBuilder(
              listenable: _importModel,
              builder: (context, _) {
                final working =
                    _importModel.phase == TakeoutImportPhase.working;
                return IconButton(
                  key: const Key('import-takeout'),
                  tooltip: 'Import from Google Takeout',
                  onPressed: working ? null : _importModel.pickAndImport,
                  icon: working
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_upload_outlined),
                );
              },
            ),
          ],
        ),
        body:
            _model.loading && _model.venues.isEmpty && _model.failedIds.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _model.venues.isEmpty && _model.failedIds.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_add_outlined, size: 52),
                      const SizedBox(height: 16),
                      Text(
                        'Save your next work spot',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bookmarks stay on this device. No account required.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: widget.onBrowse,
                        child: const Text('Browse nearby'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _model.load,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _model.venues.length + _model.failedIds.length,
                  itemBuilder: (context, index) {
                    if (index < _model.venues.length) {
                      final venue = _model.venues[index];
                      return VenueCard(
                        venue: venue,
                        saved: true,
                        onSave: () => widget.savedVenues.toggle(venue.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VenueDetailScreen(
                              initialVenue: venue,
                              venueRepository: widget.venueRepository,
                              savedVenues: widget.savedVenues,
                            ),
                          ),
                        ),
                      );
                    }
                    final failedId =
                        _model.failedIds[index - _model.venues.length];
                    return _FailedSavedRow(
                      key: Key('saved-failed-$failedId'),
                      onRemove: () => widget.savedVenues.toggle(failedId),
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
            const Expanded(child: Text("Couldn't load this saved spot.")),
            TextButton(onPressed: onRemove, child: const Text('Remove')),
          ],
        ),
      ),
    );
  }
}
