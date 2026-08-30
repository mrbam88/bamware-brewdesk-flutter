import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import 'package:brewdesk/features/saved/data/saved_venues_repository.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart'
    show VenueSnapshotLoader, loadBundledVenueSnapshot;
import 'package:brewdesk/features/saved/domain/takeout_import_service.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';

enum TakeoutImportPhase { idle, working, done, fileFailed }

const _typeGroup = XTypeGroup(
  label: 'Takeout export',
  extensions: ['csv', 'json', 'geojson'],
);

Future<XFile?> _defaultPickFile() =>
    openFile(acceptedTypeGroups: const [_typeGroup]);

/// Drives a Google Takeout import from the Saved screen: pick a file,
/// parse + match it on-device against the bundled venue catalog, then save
/// the confirmed matches. Nothing here makes a network call — matching
/// reads the same bundled snapshot cold start uses, never the live API.
class TakeoutImportViewModel extends ChangeNotifier {
  TakeoutImportViewModel({
    required this._savedVenues,
    VenueSnapshotLoader? venuesLoader,
    Future<XFile?> Function()? pickFile,
  }) : _loadVenues = venuesLoader ?? loadBundledVenueSnapshot,
       _pickFile = pickFile ?? _defaultPickFile;

  final SavedVenuesRepository _savedVenues;
  final VenueSnapshotLoader _loadVenues;
  final Future<XFile?> Function() _pickFile;

  TakeoutImportPhase _phase = TakeoutImportPhase.idle;
  List<Venue> _matched = const [];
  List<TakeoutPlace> _unmatched = const [];

  TakeoutImportPhase get phase => _phase;
  List<Venue> get matched => List.unmodifiable(_matched);
  List<TakeoutPlace> get unmatched => List.unmodifiable(_unmatched);

  /// Opens the file picker and, if a file was chosen, parses + matches it.
  /// Leaves [phase] at `idle` when the user cancels the picker.
  Future<void> pickAndImport() async {
    final XFile? file;
    try {
      file = await _pickFile();
    } on Object {
      _phase = TakeoutImportPhase.fileFailed;
      notifyListeners();
      return;
    }
    if (file == null) return;

    _phase = TakeoutImportPhase.working;
    notifyListeners();

    final List<TakeoutPlace> places;
    try {
      final bytes = await file.readAsBytes();
      places = TakeoutParser.parse(utf8.decode(bytes, allowMalformed: true));
    } on Object {
      _phase = TakeoutImportPhase.fileFailed;
      notifyListeners();
      return;
    }

    final venues = await _loadVenues();
    final result = TakeoutMatcher.match(places, venues);
    _matched = result.matched;
    _unmatched = result.unmatched;
    _phase = TakeoutImportPhase.done;
    notifyListeners();
  }

  /// Saves every matched venue not already saved, then resets to idle.
  Future<void> confirm() async {
    for (final venue in _matched) {
      if (!_savedVenues.contains(venue.id)) {
        await _savedVenues.toggle(venue.id);
      }
    }
    reset();
  }

  void reset() {
    _phase = TakeoutImportPhase.idle;
    _matched = const [];
    _unmatched = const [];
    notifyListeners();
  }
}
