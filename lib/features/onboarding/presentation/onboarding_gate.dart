import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:brewdesk/core/location/location_mode.dart';
import 'package:brewdesk/features/onboarding/data/onboarding_service.dart';
import 'package:brewdesk/features/onboarding/presentation/onboarding_flow.dart';

/// Gates [child] behind the onboarding + location-intro flow.
///
/// Fresh installs (or a run started with the `BREWDESK_RESET_ONBOARDING`
/// dart-define — see [OnboardingService]) see [OnboardingFlow] first. Once
/// it completes, this widget renders [child] directly on every later launch.
///
/// The flow's outcome — use the real device location, or the fixed Union
/// Square resolver that never triggers the OS prompt — is published to
/// [LocationModeController]; consumers read the resolved service from
/// [effectiveLocationServiceProvider] instead of receiving it here.
// LEARN: this gate used to await SharedPreferences.getInstance() itself
// (a second lookup of a dependency main() already had), which forced a
// nullable `_complete` and a spinner frame on every launch. Reading the
// service from the graph is synchronous, so the widget models exactly two
// states: onboarding, or the app. `ConsumerStatefulWidget` = a stateful
// widget with `ref` — the useContext-enabled component of Riverpod.
class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate> {
  // LEARN: ref.read (not watch) — this is an init-time snapshot by design:
  // completing onboarding must swap to the app on THIS launch only via the
  // callback below, never by a provider rebuild yanking the flow mid-page.
  late bool _complete = ref.read(onboardingServiceProvider).isComplete;

  Future<void> _handleOnboardingComplete(bool useDeviceLocation) async {
    await ref.read(onboardingServiceProvider).markComplete();
    if (!mounted) return;
    ref
        .read(locationModeControllerProvider.notifier)
        .select(
          useDeviceLocation ? LocationMode.device : LocationMode.unionSquare,
        );
    setState(() => _complete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_complete) {
      return OnboardingFlow(onComplete: _handleOnboardingComplete);
    }
    return widget.child;
  }
}
