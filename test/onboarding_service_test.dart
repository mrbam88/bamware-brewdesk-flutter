import 'package:brewdesk/features/onboarding/data/onboarding_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('fresh install is incomplete until markComplete is called', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = OnboardingService(preferences);

    expect(service.isComplete, isFalse);

    await service.markComplete();

    expect(service.isComplete, isTrue);
  });

  test('completion persists for a new instance sharing preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await OnboardingService(preferences).markComplete();

    final restored = OnboardingService(preferences);

    expect(restored.isComplete, isTrue);
  });

  test(
    'resetRequested forces onboarding to show even if already complete',
    () async {
      SharedPreferences.setMockInitialValues({
        'brewdesk.onboarding.complete': true,
      });
      final preferences = await SharedPreferences.getInstance();

      final service = OnboardingService(preferences, resetRequested: true);

      expect(service.isComplete, isFalse);
    },
  );
}
