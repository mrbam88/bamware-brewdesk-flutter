import 'package:flutter/material.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../core/venue_widgets.dart';
import '../venue_detail/venue_detail_screen.dart';
import 'saved_view_model.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
    required this.venueRepository,
    required this.savedVenues,
    required this.onBrowse,
  });

  final VenueRepository venueRepository;
  final SavedVenuesRepository savedVenues;
  final VoidCallback onBrowse;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late final SavedViewModel _model = SavedViewModel(
    widget.venueRepository,
    widget.savedVenues,
  );

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
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Saved')),
        body: _model.loading && _model.venues.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _model.venues.isEmpty
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
                  itemCount: _model.venues.length,
                  itemBuilder: (context, index) {
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
                  },
                ),
              ),
      ),
    );
  }
}
