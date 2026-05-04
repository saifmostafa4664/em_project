import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import 'rfid_scan_event.dart';

/// Singleton service for communicating with Arduino RFID reader via USB Serial.
class SerialService extends ChangeNotifier {
  // ── Singleton ──
  static final SerialService instance = SerialService._internal();
  SerialService._internal();

  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;
  String _buffer = '';

  // ── Public State ──
  bool _isConnected = false;
  String? _connectedPortName;
  String _lastError = '';

  bool get isConnected => _isConnected;
  String? get connectedPortName => _connectedPortName;
  String get lastError => _lastError;

  // ── Scan Stream ──
  final _scanController = StreamController<RfidScanEvent>.broadcast();
  Stream<RfidScanEvent> get scanStream => _scanController.stream;

  /// Lists all available serial ports on this machine.
  List<String> getAvailablePorts() {
    try {
      return SerialPort.availablePorts;
    } catch (e) {
      debugPrint('SerialService: Error listing ports: $e');
      return [];
    }
  }

  /// Returns a human-readable description for a port name.
  String getPortDescription(String portName) {
    try {
      final port = SerialPort(portName);
      final desc = port.description ?? portName;
      port.dispose();
      return desc;
    } catch (_) {
      return portName;
    }
  }

  /// Connect to the specified serial port.
  bool connect(String portName, {int baudRate = 9600}) {
    // Disconnect existing connection first
    if (_isConnected) {
      disconnect();
    }

    try {
      _port = SerialPort(portName);

      if (!_port!.openReadWrite()) {
        _lastError = 'فشل فتح المنفذ: ${SerialPort.lastError}';
        notifyListeners();
        return false;
      }

      // Configure port
      final config = SerialPortConfig()
        ..baudRate = baudRate
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none;
      _port!.config = config;

      // Start reading
      _reader = SerialPortReader(_port!, timeout: 1000);
      _buffer = '';

      _subscription = _reader!.stream.listen(
        _onDataReceived,
        onError: (error) {
          debugPrint('SerialService: Read error: $error');
          _lastError = 'خطأ في القراءة: $error';
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('SerialService: Stream done');
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _connectedPortName = portName;
      _lastError = '';
      notifyListeners();

      debugPrint('SerialService: Connected to $portName at $baudRate baud');
      return true;
    } catch (e) {
      _lastError = 'خطأ في الاتصال: $e';
      debugPrint('SerialService: Connection error: $e');
      _port?.dispose();
      _port = null;
      notifyListeners();
      return false;
    }
  }

  /// Disconnect from the current serial port.
  void disconnect() {
    _subscription?.cancel();
    _subscription = null;

    _reader?.close();
    _reader = null;

    if (_port != null && _port!.isOpen) {
      _port!.close();
    }
    _port?.dispose();
    _port = null;

    _isConnected = false;
    _connectedPortName = null;
    _buffer = '';
    notifyListeners();

    debugPrint('SerialService: Disconnected');
  }

  /// Process incoming serial data.
  void _onDataReceived(Uint8List data) {
    final chunk = utf8.decode(data, allowMalformed: true);
    _buffer += chunk;

    // Process complete lines (terminated by \n)
    while (_buffer.contains('\n')) {
      final lineEnd = _buffer.indexOf('\n');
      final line = _buffer.substring(0, lineEnd).trim();
      _buffer = _buffer.substring(lineEnd + 1);

      if (line.isEmpty) continue;

      // Skip the "RFID_READY" handshake message
      if (line == 'RFID_READY') {
        debugPrint('SerialService: Arduino RFID module is ready');
        continue;
      }

      // Try to parse JSON {"uid":"XXXXXXXX"}
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final uid = json['uid'] as String?;
        if (uid != null && uid.isNotEmpty) {
          final event = RfidScanEvent(
            cardUid: uid,
            timestamp: DateTime.now(),
          );
          debugPrint('SerialService: Card scanned → $uid');
          _scanController.add(event);
        }
      } catch (_) {
        // Not valid JSON, could be debug output from Arduino
        debugPrint('SerialService: Non-JSON data: $line');
      }
    }
  }

  /// Handle unexpected disconnection.
  void _handleDisconnect() {
    _isConnected = false;
    _connectedPortName = null;
    notifyListeners();
  }

  /// Clean up resources.
  @override
  void dispose() {
    disconnect();
    _scanController.close();
    super.dispose();
  }
}
