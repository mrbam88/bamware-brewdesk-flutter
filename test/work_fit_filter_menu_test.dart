import 'dart:convert';

import 'package:brewdesk/data/repositories/venue_repository.dart';
import 'package:brewdesk/data/services/location_service.dart';
import 'package:brewdesk/data/services/venue_api.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/ui/features/discovery/discovery_view_model.dart';
import 'package:brewdesk/ui/features/discovery/work_fit_filter_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<DiscoveryViewModel> _emptyModel() async {
  final client = MockClient(
    (request) async =>
        http.Response(jsonEncode({'meta': {}, 'venues': []}), 200),
  );
  final repository = VenueRepository(
    VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
  );
  final model = DiscoveryViewModel(repository, const LocationService());
  await model.load(useDeviceLocation: false);
  return model;
}

void main() {
  testWidgets('badge count tracks active filters and Reset clears them all', (
    tester,
  ) async {
    final model = await _emptyModel();

    // The popover is anchored below the button and needs more vertical
    // room than the default 800x600 test surface to hit-test cleanly.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: WorkFitFilterButton(model: model),
          ),
        ),
      ),
    );

    // No filters active yet: no badge.
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();

    // No filters active: the Reset row is absent entirely, not just disabled.
    expect(find.byKey(const Key('filters-reset')), findsNothing);

    // Turn on Laptop friendly and pick a Wi-Fi floor: two active filters.
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-wifi-fast')));
    await tester.pumpAndSettle();

    expect(model.activeFilterCount, 2);
    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('Reset 2 filters'), findsOneWidget);

    await tester.tap(find.byKey(const Key('filters-reset')));
    await tester.pumpAndSettle();

    expect(model.activeFilterCount, 0);
    expect(model.laptopFriendly, isFalse);
    expect(model.minWifi, isNull);
    // brewdesk#28: the Reset row disappears entirely once there is nothing
    // left to reset, rather than sitting there disabled.
    expect(find.byKey(const Key('filters-reset')), findsNothing);
    expect(find.text('2'), findsNothing);
  });
}
