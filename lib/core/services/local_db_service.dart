import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDbService {
  static final LocalDbService instance = LocalDbService._internal();
  LocalDbService._internal();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;

    if (kIsWeb) return;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbDir = Directory(p.join(
      Platform.environment['HOME'] ?? '.',
      '.em_project',
    ));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final dbPath = p.join(dbDir.path, 'rfid_scans.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE rfid_scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            card_uid TEXT NOT NULL,
            scan_time TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            student_name TEXT,
            student_id TEXT
          )
        ''');
        debugPrint('LocalDbService: Database created at $dbPath');
      },
    );

    debugPrint('LocalDbService: Database initialized at $dbPath');
  }

  Future<int> insertScan({
    required String cardUid,
    required DateTime scanTime,
    String? studentName,
    String? studentId,
  }) async {
    final db = _db;
    if (db == null) throw StateError('Database not initialized');

    final id = await db.insert('rfid_scans', {
      'card_uid': cardUid,
      'scan_time': scanTime.toIso8601String(),
      'synced': 0,
      'student_name': studentName,
      'student_id': studentId,
    });

    debugPrint('LocalDbService: Inserted scan #$id (uid: $cardUid)');
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllScans() async {
    final db = _db;
    if (db == null) return [];

    return db.query('rfid_scans', orderBy: 'scan_time DESC');
  }

  Future<List<Map<String, dynamic>>> getTodayScans() async {
    final db = _db;
    if (db == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return db.query(
      'rfid_scans',
      where: 'scan_time >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'scan_time DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedScans() async {
    final db = _db;
    if (db == null) return [];

    return db.query(
      'rfid_scans',
      where: 'synced = 0',
      orderBy: 'scan_time ASC',
    );
  }

  Future<void> markSynced(int id) async {
    final db = _db;
    if (db == null) return;

    await db.update(
      'rfid_scans',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markMultipleSynced(List<int> ids) async {
    final db = _db;
    if (db == null) return;

    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        'rfid_scans',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit();
  }

  Future<int> getTodayScanCount() async {
    final db = _db;
    if (db == null) return 0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rfid_scans WHERE scan_time >= ?',
      [startOfDay.toIso8601String()],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getUnsyncedCount() async {
    final db = _db;
    if (db == null) return 0;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rfid_scans WHERE synced = 0',
    );

    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
