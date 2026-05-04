import 'dart:async';
import 'package:flutter/foundation.dart';
import 'rfid_scan_event.dart';

/// Stub implementation of SerialService for Web platform.
class SerialService extends ChangeNotifier {
  static final SerialService instance = SerialService._internal();
  SerialService._internal();

  bool _isConnected = false;
  String? _connectedPortName;
  String _lastError = '';

  bool get isConnected => _isConnected;
  String? get connectedPortName => _connectedPortName;
  String get lastError => _lastError;

  final _scanController = StreamController<RfidScanEvent>.broadcast();
  Stream<RfidScanEvent> get scanStream => _scanController.stream;

  List<String> getAvailablePorts() {
    debugPrint('SerialService: Not supported on Web platform.');
    return [];
  }

  String getPortDescription(String portName) {
    return portName;
  }

  bool connect(String portName, {int baudRate = 9600}) {
    _lastError = 'Serial ports are not supported on Web.';
    notifyListeners();
    return false;
  }

  void disconnect() {
    _isConnected = false;
    _connectedPortName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanController.close();
    super.dispose();
  }
}
