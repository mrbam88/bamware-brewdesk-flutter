import 'package:brewdesk/data/services/location_service.dart';
import 'package:brewdesk/ui/features/onboarding/onboarding_gate.dart';
import 'package:brewdesk/ui/features/onboarding/union_square_location_service.dart';
import 'package:flutter/material.dart';
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

void main() {
  testWidgets('fresh install shows onboarding, not the builder', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          locationService: const _DeniedLocationService(),
          builder: (context, _) => const Scaffold(body: Text('Spots')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your next desk might serve espresso.'), findsOneWidget);
    expect(find.text('Spots'), findsNothing);
  });

  testWidgets('relaunch after completion skips straight to the builder', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'brewdesk.onboarding.complete': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          locationService: const _DeniedLocationService(),
          builder: (context, _) => const Scaffold(body: Text('Spots')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Spots'), findsOneWidget);
    expect(find.text('Your next desk might serve espresso.'), findsNothing);
  });

  testWidgets(
    '"Use Union Square instead" never touches the real location service '
    'and resolves to the Union Square fallback',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      LocationService? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingGate(
            locationService: const _ThrowingLocationService(),
            builder: (context, resolvedLocationService) {
              resolved = resolvedLocationService;
              return const Scaffold(body: Text('Spots'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find my work spot'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use Union Square instead'));
      await tester.pumpAndSettle();

      expect(find.text('Spots'), findsOneWidget);
      expect(resolved, isA<UnionSquareLocationService>());
      final location = await resolved!.currentLocation();
      expect(location, UnionSquareLocationService.unionSquare);
    },
  );

  testWidgets('"Use my location" hands the real device location service to the '
      'builder, and a decline still resolves (no crash, no value)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const deviceService = _DeniedLocationService();
    LocationService? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          locationService: deviceService,
          builder: (context, resolvedLocationService) {
            captured = resolvedLocationService;
            return const Scaffold(body: Text('Spots'));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find my work spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.text('Spots'), findsOneWidget);
    expect(identical(captured, deviceService), isTrue);
    expect(await captured!.currentLocation(), isNull);
  });
}
