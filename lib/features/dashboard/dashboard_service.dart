import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardService {
  static final _db = FirebaseFirestore.instance;

  // ── إجمالي طلاب المشرف بس ──
  static Stream<int> totalStudentsStream(String instructorId) {
    return _db
        .collection('courses')
        .where(
          'instructor_id',
          isEqualTo: int.tryParse(instructorId) ?? instructorId,
        )
        .snapshots()
        .asyncMap((coursesSnap) async {
          final Set<dynamic> allStudentIds = {};
          for (final course in coursesSnap.docs) {
            final students = List<dynamic>.from(
              course.data()['students'] ?? [],
            );
            allStudentIds.addAll(students);
          }
          return allStudentIds.length;
        });
  }

  // ── تنبيهات حرجة ──
  static Stream<int> criticalAlertsStream() {
    return _db
        .collection('attendance')
        .where('status', isEqualTo: 'absent')
        .where('is_critical', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // ── كل طلاب المشرف ──
  static Stream<List<Map<String, dynamic>>> allStudentsStream(
    String instructorId,
  ) {
    return _db
        .collection('courses')
        .where(
          'instructor_id',
          isEqualTo: int.tryParse(instructorId) ?? instructorId,
        )
        .snapshots()
        .asyncMap((coursesSnap) async {
          if (coursesSnap.docs.isEmpty) return [];

          final Set<dynamic> allStudentIds = {};
          for (final course in coursesSnap.docs) {
            final students = List<dynamic>.from(
              course.data()['students'] ?? [],
            );
            allStudentIds.addAll(students);
          }

          final List<Map<String, dynamic>> rows = [];

          for (final id in allStudentIds) {
            var query = await _db
                .collection('users')
                .where(
                  'university_id',
                  isEqualTo: int.tryParse(id.toString()) ?? id,
                )
                .limit(1)
                .get();

            if (query.docs.isEmpty) {
              query = await _db
                  .collection('users')
                  .where('university_id', isEqualTo: id.toString())
                  .limit(1)
                  .get();
            }

            if (query.docs.isNotEmpty) {
              final userData = query.docs.first.data();
              rows.add({
                'name': userData['name'] ?? 'غير معروف',
                'id': id.toString(),
                'rfidTime': '--',
                'status': 'غير محدد',
                'avatarColor': _avatarColor(id.toString()),
              });
            }
          }

          return rows;
        });
  }

  // ── الحاضرين اليوم من طلاب المشرف بس ──
  static Stream<int> presentTodayStream(String instructorId) async* {
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);

    final coursesSnap = await _db
        .collection('courses')
        .where(
          'instructor_id',
          isEqualTo: int.tryParse(instructorId) ?? instructorId,
        )
        .get();

    final Set<String> studentIds = {};
    for (final course in coursesSnap.docs) {
      final students = List<dynamic>.from(course.data()['students'] ?? []);
      studentIds.addAll(students.map((e) => e.toString()));
    }

    yield* _db
        .collection('attendance')
        .where('status', isEqualTo: 'present')
        .where(
          'scan_time',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .snapshots()
        .map(
          (s) => s.docs
              .where(
                (d) => studentIds.contains(d.data()['student_id']?.toString()),
              )
              .length,
        );
  }

  // ── الغائبين اليوم من طلاب المشرف بس ──
  static Stream<int> absentTodayStream(String instructorId) async* {
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);

    final coursesSnap = await _db
        .collection('courses')
        .where(
          'instructor_id',
          isEqualTo: int.tryParse(instructorId) ?? instructorId,
        )
        .get();

    final Set<String> studentIds = {};
    for (final course in coursesSnap.docs) {
      final students = List<dynamic>.from(course.data()['students'] ?? []);
      studentIds.addAll(students.map((e) => e.toString()));
    }

    yield* _db
        .collection('attendance')
        .where('status', isEqualTo: 'absent')
        .where(
          'scan_time',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .snapshots()
        .map(
          (s) => s.docs
              .where(
                (d) => studentIds.contains(d.data()['student_id']?.toString()),
              )
              .length,
        );
  }

  // ── حالة الأجهزة ──
  static Stream<List<Map<String, dynamic>>> devicesStream() => _db
      .collection('devices')
      .snapshots()
      .map(
        (s) => s.docs
            .map(
              (d) => {
                'name': d.data()['location'] ?? d.id,
                'connected': d.data()['is_active'] ?? false,
              },
            )
            .toList(),
      );

  // ── سجلات الحضور لكورسات المشرف ──
  static Stream<List<Map<String, dynamic>>> attendanceStream(
    String instructorId,
  ) {
    return _db
        .collection('courses')
        .where(
          'instructor_id',
          isEqualTo: int.tryParse(instructorId) ?? instructorId,
        )
        .snapshots()
        .asyncMap((coursesSnap) async {
          if (coursesSnap.docs.isEmpty) return [];

          final Set<dynamic> allStudentIds = {};
          for (final course in coursesSnap.docs) {
            final students = List<dynamic>.from(
              course.data()['students'] ?? [],
            );
            allStudentIds.addAll(students);
          }

          if (allStudentIds.isEmpty) return [];

          final List<Map<String, dynamic>> rows = [];

          for (final id in allStudentIds) {
            var query = await _db
                .collection('users')
                .where(
                  'university_id',
                  isEqualTo: int.tryParse(id.toString()) ?? id,
                )
                .limit(1)
                .get();

            if (query.docs.isEmpty) {
              query = await _db
                  .collection('users')
                  .where('university_id', isEqualTo: id.toString())
                  .limit(1)
                  .get();
            }

            if (query.docs.isNotEmpty) {
              final userData = query.docs.first.data();
              rows.add({
                'name': userData['name'] ?? 'غير معروف',
                'id': id.toString(),
                'rfidTime': '--',
                'status': 'غير محدد',
                'avatarColor': _avatarColor(id.toString()),
              });
            }
          }

          return rows;
        });
  }

  // ignore: unused_element
  static String _mapStatus(String s) {
    switch (s) {
      case 'present':
        return 'حاضر';
      case 'absent':
        return 'غائب';
      case 'late':
        return 'متأخر';
      default:
        return 'غائب';
    }
  }

  static Color _avatarColor(String id) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}
