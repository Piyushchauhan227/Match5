import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityResult>();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((onData) {
      _controller.add(onData.first);
    });
  }

  Stream<ConnectivityResult> get connectiviyStream => _controller.stream;

  Future<bool> get hasConnection async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}
