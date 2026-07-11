/// Interface to verify internet connectivity.
/// Crucial for IPTV streaming players to gracefully toggle offline or cached states.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Production implementation of network diagnostics.
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // In production, use the 'connectivity_plus' or simple socket lookup
    // e.g. await InternetConnectionChecker().hasConnection;
    return true; 
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return Stream.value(true);
  }
}
