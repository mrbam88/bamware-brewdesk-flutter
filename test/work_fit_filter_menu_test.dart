import 'package:brewdesk/features/discovery/application/discovery_filters_controller.dart';
import 'package:brewdesk/features/discovery/domain/discovery_filters.dart';
import 'package:brewdesk/features/discovery/presentation/work_fit_filter_menu.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('badge count tracks active filters and Reset clears them all', (
    tester,
  ) async {
    // The popover is anchored below the button and needs more vertical
    // room than the default 800x600 test surface to hit-test cleanly.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: WorkFitFilterButton(),
            ),
          ),
        ),
      ),
    );
    // The filter widgets need no fakes at all now — filters are pure client
    // state, so a bare ProviderScope is the whole harness. Assertions read
    // the same container the widgets use.
    DiscoveryFilters currentFilters() => ProviderScope.containerOf(
      tester.element(find.byType(WorkFitFilterButton)),
    ).read(discoveryFiltersControllerProvider);

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

    expect(currentFilters().activeCount, 2);
    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('Reset 2 filters'), findsOneWidget);

    await tester.tap(find.byKey(const Key('filters-reset')));
    await tester.pumpAndSettle();

    final filters = currentFilters();
    expect(filters.activeCount, 0);
    expect(filters.laptopFriendly, isFalse);
    expect(filters.minWifi, isNull);
    // brewdesk#28: the Reset row disappears entirely once there is nothing
    // left to reset, rather than sitting there disabled.
    expect(find.byKey(const Key('filters-reset')), findsNothing);
    expect(find.text('2'), findsNothing);
  });
}
