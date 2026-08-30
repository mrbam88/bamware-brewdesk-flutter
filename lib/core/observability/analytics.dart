import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics.g.dart';

@Riverpod(keepAlive: true)
Analytics analytics(Ref ref) => const DebugAnalytics();

/// Product analytics sink. The MVP ships no vendor SDK; this interface is
/// where one would plug in, and [DebugAnalytics] proves the call sites out.
abstract interface class Analytics {
  void track(String event, [Map<String, Object?> properties]);
}

class DebugAnalytics implements Analytics {
  const DebugAnalytics();

  @override
  void track(String event, [Map<String, Object?> properties = const {}]) {
    developer.log('$event $properties', name: 'analytics');
  }
}
