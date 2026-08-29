import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/location_service.dart';
import 'onboarding_flow.dart';
import 'onboarding_service.dart';
import 'union_square_location_service.dart';

/// Gates [builder] behind the onboarding + location-intro flow.
///
/// Fresh installs (or a run started with the `BREWDESK_RESET_ONBOARDING`
/// dart-define — see [OnboardingService]) see [OnboardingFlow] first. Once
/// it completes, this widget renders [builder] directly on every later
/// launch.
///
/// [builder] receives the location service resolved by the flow: the real
/// [locationService] for "Use my location" (letting it — and only it —
/// trigger the OS prompt), or a fixed Union Square resolver for
/// "Use Union Square instead".
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({
    super.key,
    required this.locationService,
    required this.builder,
  });

  final LocationService locationService;
  final Widget Function(BuildContext context, LocationService locationService)
  builder;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  OnboardingService? _service;
  bool? _complete;
  LocationService? _resolvedLocationService;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final preferences = await SharedPreferences.getInstance();
    final service = OnboardingService(preferences);
    if (!mounted) return;
    setState(() {
      _service = service;
      _complete = service.isComplete;
    });
  }

  Future<void> _handleOnboardingComplete(bool useDeviceLocation) async {
    final service = _service;
    if (service == null) return;
    await service.markComplete();
    if (!mounted) return;
    setState(() {
      _complete = true;
      _resolvedLocationService = useDeviceLocation
          ? widget.locationService
          : const UnionSquareLocationService();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_complete == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_complete!) {
      return OnboardingFlow(onComplete: _handleOnboardingComplete);
    }
    return widget.builder(
      context,
      _resolvedLocationService ?? widget.locationService,
    );
  }
}
