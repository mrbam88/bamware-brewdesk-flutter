import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brewdesk/core/di/app_providers.dart';

part 'onboarding_service.g.dart';

@Riverpod(keepAlive: true)
OnboardingService onboardingService(Ref ref) =>
    OnboardingService(ref.watch(sharedPreferencesProvider));

/// Persists whether the onboarding + location-intro flow has been completed.
///
/// [resetRequested] defaults to the `BREWDESK_RESET_ONBOARDING` dart-define
/// (`--dart-define=BREWDESK_RESET_ONBOARDING=true`): a launch-time seam that
/// forces onboarding to show again on a device/run that already completed
/// it, for manual QA re-runs and on-device integration tests. Widget tests
/// can instead pass [resetRequested] directly rather than relaunching with a
/// different define.
class OnboardingService {
  const OnboardingService(
    this._preferences, {
    this.resetRequested = _resetFromEnvironment,
  });

  static const _key = 'brewdesk.onboarding.complete';
  static const _resetFromEnvironment = bool.fromEnvironment(
    'BREWDESK_RESET_ONBOARDING',
  );

  final SharedPreferences _preferences;
  final bool resetRequested;

  bool get isComplete =>
      !resetRequested && (_preferences.getBool(_key) ?? false);

  Future<void> markComplete() => _preferences.setBool(_key, true);
}
