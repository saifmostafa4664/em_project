class RfidScanEvent {
  final String cardUid;
  final DateTime timestamp;

  RfidScanEvent({required this.cardUid, required this.timestamp});

  Map<String, dynamic> toMap() => {
        'card_uid': cardUid,
        'scan_time': timestamp.toIso8601String(),
      };

  @override
  String toString() => 'RfidScanEvent(uid: $cardUid, time: $timestamp)';
}
