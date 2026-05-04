import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'local_db_service.dart';

/// Service to sync locally-stored RFID scans to Firebase Firestore.
class SyncService {
  // ── Singleton ──
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  final _db = LocalDbService.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Sync all unsynced RFID scans to Firebase `attendance` collection.
  ///
  /// For each scan, it looks up the student by `card_id` in the `users`
  /// collection to attach name and university_id to the attendance record.
  ///
  /// Returns the number of successfully synced records.
  Future<int> syncToFirebase() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    try {
      final unsyncedScans = await _db.getUnsyncedScans();

      if (unsyncedScans.isEmpty) {
        debugPrint('SyncService: No unsynced scans to upload');
        return 0;
      }

      debugPrint('SyncService: Syncing ${unsyncedScans.length} scans...');

      int successCount = 0;

      for (final scan in unsyncedScans) {
        try {
          final cardUid = scan['card_uid'] as String;
          final scanTimeStr = scan['scan_time'] as String;
          final scanTime = DateTime.parse(scanTimeStr);
          final localId = scan['id'] as int;

          // Look up student by card_id in users collection
          String? studentName;
          String? studentId;

          final userQuery = await _firestore
              .collection('users')
              .where('card_id', isEqualTo: cardUid)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            final userData = userQuery.docs.first.data();
            studentName = userData['name']?.toString();
            studentId = userData['university_id']?.toString();
          }

          // Create attendance record in Firebase
          await _firestore.collection('attendance').add({
            'card_id': cardUid,
            'student_id': studentId ?? 'unknown',
            'student_name': studentName ?? 'غير معروف',
            'scan_time': Timestamp.fromDate(scanTime),
            'lecture_date': Timestamp.fromDate(
              DateTime(scanTime.year, scanTime.month, scanTime.day),
            ),
            'status': 'present',
            'device_id': 'USB-RFID',
            'synced_at': Timestamp.now(),
            'source': 'local_rfid',
          });

          // Mark as synced locally
          await _db.markSynced(localId);

          // Also update local record with student info if found
          if (studentName != null || studentId != null) {
            // The student_name and student_id in local DB stay for reference
          }

          successCount++;
        } catch (e) {
          debugPrint('SyncService: Error syncing scan: $e');
          // Continue with next scan
        }
      }

      debugPrint('SyncService: Synced $successCount/${unsyncedScans.length} scans');
      return successCount;
    } finally {
      _isSyncing = false;
    }
  }
}
