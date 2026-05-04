// lib/seed_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> seedDatabase() async {
  final db = FirebaseFirestore.instance;

  // ── Users (طلاب) ──
  final students = [
    {
      'university_id': 121107,
      'name': 'saif',
      'last_name': 'mostafa',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD001',
      'email': 'saif@6otu.edu',
      'department': 'IT',
      'year': '3',
      'is_active': true
    },
    {
      'university_id': 121281,
      'name': 'omar',
      'last_name': 'ahmed',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD002',
      'email': 'omar@6otu.edu',
      'department': 'IT',
      'year': '3',
      'is_active': true
    },
    {
      'university_id': 121244,
      'name': 'Ahmed',
      'last_name': 'ali',
      'password': '4664',
      'role': 'student',
      'card_id': 'CARD003',
      'email': 'ahmed@6otu.edu',
      'department': 'IT',
      'year': '4',
      'is_active': true
    },
    {
      'university_id': 121300,
      'name': 'مريم',
      'last_name': 'خالد',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD004',
      'email': 'mariam@6otu.edu',
      'department': 'CS',
      'year': '2',
      'is_active': true
    },
    {
      'university_id': 121301,
      'name': 'كريم',
      'last_name': 'محمد',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD005',
      'email': 'karim@6otu.edu',
      'department': 'CS',
      'year': '2',
      'is_active': true
    },
    {
      'university_id': 121302,
      'name': 'نور',
      'last_name': 'سامي',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD006',
      'email': 'nour@6otu.edu',
      'department': 'IT',
      'year': '1',
      'is_active': true
    },
    {
      'university_id': 121303,
      'name': 'يوسف',
      'last_name': 'عمر',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD007',
      'email': 'youssef@6otu.edu',
      'department': 'CS',
      'year': '4',
      'is_active': true
    },
    {
      'university_id': 121304,
      'name': 'فاطمة',
      'last_name': 'حسن',
      'password': '123456',
      'role': 'student',
      'card_id': 'CARD008',
      'email': 'fatma@6otu.edu',
      'department': 'IT',
      'year': '3',
      'is_active': true
    },
  ];

  // ── Users (مشرفين) ──
  final instructors = [
    {
      'university_id': 100,
      'name': 'Dr Ahmed',
      'password': '123456',
      'role': 'instructor',
      'card_id': 'INS001',
      'email': 'drahmed@6otu.edu',
      'department': 'IT',
      'is_active': true
    },
    {
      'university_id': 101,
      'name': 'Dr Sara',
      'password': '123456',
      'role': 'instructor',
      'card_id': 'INS002',
      'email': 'drsara@6otu.edu',
      'department': 'CS',
      'is_active': true
    },
  ];

  // ── Courses ──
  final courses = [
    {
      'course_name': 'AI',
      'course_code': 1016,
      'instructor_id': 100,
      'device_id': 'RFID-A1',
      'schedule': {'day': 'Sunday', 'hall': 'قاعة A1', 'start_time': '10:30'},
      'students': [121107, 121281, 121244, 121300],
    },
    {
      'course_name': 'Database Systems',
      'course_code': 1020,
      'instructor_id': 100,
      'device_id': 'RFID-B2',
      'schedule': {'day': 'Tuesday', 'hall': 'قاعة B2', 'start_time': '12:00'},
      'students': [121107, 121301, 121302],
    },
    {
      'course_name': 'Networks',
      'course_code': 1030,
      'instructor_id': 101,
      'device_id': 'RFID-C3',
      'schedule': {
        'day': 'Wednesday',
        'hall': 'قاعة C3',
        'start_time': '09:00'
      },
      'students': [121303, 121304, 121244],
    },
  ];

  // ── Attendance (سجلات حضور تجريبية) ──
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final attendance = [
    {
      'student_id': '121107',
      'student_name': 'saif',
      'course_id': '',
      'device_id': 'RFID-A1',
      'card_id': 'CARD001',
      'scan_time':
          Timestamp.fromDate(today.add(const Duration(hours: 10, minutes: 5))),
      'status': 'present',
      'lecture_date': Timestamp.fromDate(today)
    },
    {
      'student_id': '121281',
      'student_name': 'omar',
      'course_id': '',
      'device_id': 'RFID-A1',
      'card_id': 'CARD002',
      'scan_time':
          Timestamp.fromDate(today.add(const Duration(hours: 10, minutes: 12))),
      'status': 'present',
      'lecture_date': Timestamp.fromDate(today)
    },
    {
      'student_id': '121244',
      'student_name': 'Ahmed',
      'course_id': '',
      'device_id': 'RFID-A1',
      'card_id': 'CARD003',
      'scan_time':
          Timestamp.fromDate(today.add(const Duration(hours: 10, minutes: 30))),
      'status': 'late',
      'lecture_date': Timestamp.fromDate(today)
    },
    {
      'student_id': '121300',
      'student_name': 'مريم',
      'course_id': '',
      'device_id': 'RFID-A1',
      'card_id': 'CARD004',
      'scan_time': Timestamp.fromDate(today),
      'status': 'absent',
      'lecture_date': Timestamp.fromDate(today)
    },
  ];

  // ── Devices ──
  final devices = [
    {
      'device_id': 'RFID-A1',
      'location': 'قاعة A1',
      'course_id': '1',
      'is_active': true,
      'last_ping': Timestamp.now()
    },
    {
      'device_id': 'RFID-B2',
      'location': 'قاعة B2',
      'course_id': '2',
      'is_active': true,
      'last_ping': Timestamp.now()
    },
    {
      'device_id': 'RFID-C3',
      'location': 'قاعة C3',
      'course_id': '3',
      'is_active': false,
      'last_ping': Timestamp.now()
    },
  ];

  debugPrint('🚀 بدأ رفع الداتا...');

  // رفع الطلاب
  for (final s in students) {
    await db.collection('users').add(s);
    debugPrint('✅ طالب: ${s['name']}');
  }

  // رفع المشرفين
  for (final i in instructors) {
    await db.collection('users').add(i);
    debugPrint('✅ مشرف: ${i['name']}');
  }

  // رفع الكورسات
  for (final c in courses) {
    await db.collection('courses').add(c);
    debugPrint('✅ كورس: ${c['course_name']}');
  }

  // رفع الحضور
  for (final a in attendance) {
    await db.collection('attendance').add(a);
    debugPrint('✅ حضور: ${a['student_name']}');
  }

  // رفع الأجهزة
  for (final d in devices) {
    await db.collection('devices').doc(d['device_id'] as String).set(d);
    debugPrint('✅ جهاز: ${d['device_id']}');
  }

  debugPrint('🎉 تم رفع كل الداتا بنجاح!');
}
