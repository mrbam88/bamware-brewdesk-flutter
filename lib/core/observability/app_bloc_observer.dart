import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';

import 'package:brewdesk/core/observability/analytics.dart';

// LEARN: one BlocObserver instruments EVERY bloc's every transition — the
// "funnel you can see" pattern. Because state changes only happen through
// events, logging (event, from-state, to-state) here yields a complete,
// centralized funnel trace with zero calls sprinkled through feature code.
// This is what Redux middleware/devtools gave you, and it is the concrete
// payoff of the Bloc ceremony: try writing this once for scattered
// setState calls. Wired in main.dart via Bloc.observer.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._analytics);

  final Analytics _analytics;

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    _analytics.track('bloc_transition', {
      'bloc': bloc.runtimeType.toString(),
      'event': transition.event.runtimeType.toString(),
      'from': transition.currentState.runtimeType.toString(),
      'to': transition.nextState.runtimeType.toString(),
    });
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log(
      'unhandled in ${bloc.runtimeType}',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
