import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) =>
    const ConnectivityService();

/// Thin wrapper over connectivity_plus: callers only need "am I online now
/// or not", never the specific transport. Kept as an overridable class (the
/// [LocationService] pattern) so widget tests can substitute a controlled
/// stream instead of the real platform channel (brewdesk#11 offline
/// auto-retry).
class ConnectivityService {
  const ConnectivityService();

  /// Emits `true`/`false` as the device gains or loses a network path.
  Stream<bool> get onlineChanges => Connectivity().onConnectivityChanged.map(
    (results) => results.any((result) => result != ConnectivityResult.none),
  );
}
