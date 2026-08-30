import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/core/location/location_mode.dart';
import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/onboarding/presentation/onboarding_gate.dart';
import 'package:brewdesk/core/location/union_square_location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fails the test if it is ever asked for a location — stands in for the
/// real device location service so a test can prove a code path never
/// triggers the OS permission prompt.
class _ThrowingLocationService extends LocationService {
  const _ThrowingLocationService();

  @override
  Future<LatLng?> currentLocation() {
    fail('the real device LocationService must not be called here');
  }
}

/// Stands in for a device that has declined the OS location prompt.
class _DeniedLocationService extends LocationService {
  const _DeniedLocationService();

  @override
  Future<LatLng?> currentLocation() async => null;
}

Future<void> _pumpGate(
  WidgetTester tester, {
  required LocationService deviceLocationService,
}) async {
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        locationServiceProvider.overrideWithValue(deviceLocationService),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingGate(child: Scaffold(body: Text('Spots'))),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The service discovery will actually use — what the flow "resolves" now
/// that the gate publishes a [LocationMode] instead of handing a service to
/// a builder callback.
// LEARN: ProviderScope.containerOf reads the same container the widgets use
// — the standard way for a widget test to assert on provider state.
LocationService _effectiveService(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(OnboardingGate)),
    ).read(effectiveLocationServiceProvider);

Future<void> _completeFlow(WidgetTester tester, {required String choice}) async {
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Find my work spot'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(choice));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fresh install shows onboarding, not the app', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpGate(tester, deviceLocationService: const _DeniedLocationService());

    expect(find.text('Your next desk might serve espresso.'), findsOneWidget);
    expect(find.text('Spots'), findsNothing);
  });

  testWidgets('relaunch after completion skips straight to the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'brewdesk.onboarding.complete': true,
    });
    await _pumpGate(tester, deviceLocationService: const _DeniedLocationService());

    expect(find.text('Spots'), findsOneWidget);
    expect(find.text('Your next desk might serve espresso.'), findsNothing);
  });

  testWidgets(
    '"Use Union Square instead" never touches the real location service '
    'and resolves to the Union Square fallback',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await _pumpGate(
        tester,
        deviceLocationService: const _ThrowingLocationService(),
      );
      await _completeFlow(tester, choice: 'Use Union Square instead');

      expect(find.text('Spots'), findsOneWidget);
      final resolved = _effectiveService(tester);
      expect(resolved, isA<UnionSquareLocationService>());
      expect(
        await resolved.currentLocation(),
        UnionSquareLocationService.unionSquare,
      );
    },
  );

  testWidgets('"Use my location" resolves to the real device location '
      'service, and a decline still resolves (no crash, no value)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const deviceService = _DeniedLocationService();
    await _pumpGate(tester, deviceLocationService: deviceService);
    await _completeFlow(tester, choice: 'Use my location');

    expect(find.text('Spots'), findsOneWidget);
    expect(identical(_effectiveService(tester), deviceService), isTrue);
    expect(await _effectiveService(tester).currentLocation(), isNull);
  });
}
