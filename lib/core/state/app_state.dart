import 'package:flutter/material.dart';

enum UserRole { student, supervisor }

enum NavIndex { home, records, schedule, profile }

class AppState extends ChangeNotifier {
  // Singleton pattern
  static final AppState instance = AppState._internal();
  AppState._internal();

  final bool _isLoading = false;

  String studentName = 'أحمد محمد';
  int attendancePercent = 92;
  int absenceDays = 2;
  int totalLectures = 12;
  int totalStudentsToday = 240;
  int presentNow = 232;
  int absentCount = 8;
  int criticalAlerts = 1;

  final List<Map<String, dynamic>> records = [
    {
      'subject': 'محاضرة هندسة البرمجيات',
      'date': '01 أبريل 2026',
      'time': '10:00 ص',
      'status': 'حاضر',
    },
    {
      'subject': 'محاضرة نظم المعلومات',
      'date': '31 مارس 2026',
      'time': '12:30 م',
      'status': 'غائب',
    },
    {
      'subject': 'محاضرة قواعد البيانات',
      'date': '29 مارس 2026',
      'time': '09:15 ص',
      'status': 'حاضر',
    },
    {
      'subject': 'محاضرة شبكات الحاسوب',
      'date': '27 مارس 2026',
      'time': '11:00 ص',
      'status': 'حاضر',
    },
  ];

  final List<Map<String, dynamic>> attendanceTableData = [
    {
      'name': 'أحمد محمد علي',
      'id': '202401001',
      'rfidTime': '08:05 ص',
      'status': 'حاضر',
      'avatarColor': const Color(0xFF4E97FF),
    },
    {
      'name': 'سارة محمود حسن',
      'id': '202401002',
      'rfidTime': '08:11 ص',
      'status': 'غائب',
      'avatarColor': const Color(0xFFF3A632),
    },
    {
      'name': 'ياسين إبراهيم',
      'id': '202401003',
      'rfidTime': '08:03 ص',
      'status': 'حاضر',
      'avatarColor': const Color(0xFF9C27B0),
    },
  ];

  final List<Map<String, dynamic>> deviceStatus = [
    {'name': 'البوابة الرئيسية - A1', 'connected': true},
    {'name': 'قاعة المحاضرات - L4', 'connected': true},
    {'name': 'المختبر الرقمي - C2', 'connected': false},
  ];

  final List<double> weeklyData = [72, 85, 68, 91, 78, 88, 84];

  // ── Auth ──────────────────────────────────────────────────────────────────
  UserRole _role = UserRole.student;
  bool _isLoggedIn = false;
  bool _rememberMe = false;

  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  String? currentUserId;
  String? currentUserName;
  String? currentUserRole;

  void login({required UserRole role, String? userId, String? userName}) {
    _isLoggedIn = true;
    _role = role;
    currentUserId = userId;
    currentUserName = userName;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void setRememberMe(bool val) {
    _rememberMe = val;
    notifyListeners();
  }

  // ── Bottom Nav (Student) ──────────────────────────────────────────────────
  NavIndex _navIndex = NavIndex.home;
  NavIndex get navIndex => _navIndex;

  void setNavIndex(NavIndex idx) {
    _navIndex = idx;
    notifyListeners();
  }

  // ── RFID State ────────────────────────────────────────────────────────────
  bool isRfidConnected = false;
  String? connectedPort;
  List<Map<String, dynamic>> recentScans = [];
  int todayScanCount = 0;

  void updateRfidConnection(bool connected, String? port) {
    isRfidConnected = connected;
    connectedPort = port;
    notifyListeners();
  }

  void addScan(Map<String, dynamic> scan) {
    recentScans.insert(0, scan);
    todayScanCount++;
    notifyListeners();
  }
}
