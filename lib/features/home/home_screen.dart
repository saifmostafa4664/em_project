import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../shared/widgets/student_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.darkNavy,
      statusBarIconBrightness: Brightness.light,
    ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              // ── AppBar
              _HomeAppBar(),

              // ── Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Greeting
                      _GreetingCard(appState: appState),
                      const SizedBox(height: 14),

                      // Attendance Stat Card
                      _AttendanceStatCard(appState: appState),
                      const SizedBox(height: 14),

                      // Absence Alert
                      _AbsenceAlertCard(),
                      const SizedBox(height: 14),

                      // Upcoming Lecture
                      _UpcomingLectureCard(),
                      const SizedBox(height: 14),

                      // Recent Records
                      _RecentRecordsSection(appState: appState),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const StudentBottomNav(),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkNavy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assest/logo/363331987_257713613788245_2395123892953238221_n 1.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '6OTU Attendance',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle_outlined,
                    color: AppColors.textWhite, size: 26),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting Card ─────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final AppState appState;
  const _GreetingCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أهلاً، ${appState.studentName} 👋',
          style: const TextStyle(
            fontFamily: 'Zain',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'يوم دراسي موفق في جامعة 6 أكتوبر التكنولوجية',
          style: TextStyle(
            fontFamily: 'Zain',
            fontSize: 13,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

// ── Attendance Stat Card ──────────────────────────────────────────────────────
class _AttendanceStatCard extends StatelessWidget {
  final AppState appState;
  const _AttendanceStatCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final percent = appState.attendancePercent / 100;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'نسبة الحضور الإجمالية',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ring
          CircularPercentIndicator(
            radius: 75.0,
            lineWidth: 10.0,
            percent: percent,
            animation: true,
            animationDuration: 1200,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${appState.attendancePercent}%',
                  style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const Text(
                  'جيد جداً',
                  style: TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.bgLight,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(
                label: 'المحاضرات\nالمسجلة',
                value: '${appState.totalLectures}',
                valueColor: AppColors.textDark,
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              _MiniStat(
                label: 'أيام الغياب',
                value: '${appState.absenceDays}',
                valueColor: AppColors.statusAbsent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MiniStat(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Zain',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Zain',
            fontSize: 12,
            color: AppColors.textLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Absence Alert Card ────────────────────────────────────────────────────────
class _AbsenceAlertCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.alertWarningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.alertWarning.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.alertWarning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.alertWarning,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'تنبيه الغياب',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.alertDanger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'لقد اقتربت من حد الغياب المسموح به في مادة الذكاء الاصطناعي. المسموح به: 3 حضور - الالتزام مطلوب.',
                  style: TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Lecture Card ─────────────────────────────────────────────────────
class _UpcomingLectureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'المحاضرة القادمة',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'هندسة البرمجيات',
            style: TextStyle(
              fontFamily: 'Zain',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 6),
              const Text(
                '10:30 صباحاً – 12:30 مساءً',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 6),
              const Text(
                'قاعة المؤتمرات – مبنى B',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'عرض التفاصيل',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Records Section ────────────────────────────────────────────────────
class _RecentRecordsSection extends StatelessWidget {
  final AppState appState;
  const _RecentRecordsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final recentTwo = appState.records.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أحدث السجلات',
              style: TextStyle(
                fontFamily: 'Zain',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'كل السجلات ',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentTwo.map((r) => _RecordItem(record: r)),
      ],
    );
  }
}

class _RecordItem extends StatelessWidget {
  final Map<String, dynamic> record;
  const _RecordItem({required this.record});

  Color _statusColor(String status) {
    switch (status) {
      case 'حاضر':
        return AppColors.statusPresent;
      case 'غائب':
        return AppColors.statusAbsent;
      default:
        return AppColors.statusLate;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'حاضر':
        return AppColors.statusPresentBg;
      case 'غائب':
        return AppColors.statusAbsentBg;
      default:
        return AppColors.statusLateBg;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'حاضر':
        return Icons.check_circle_rounded;
      case 'غائب':
        return Icons.cancel_rounded;
      default:
        return Icons.watch_later_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = record['status'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _statusBgColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_statusIcon(status), color: _statusColor(status), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['subject'],
                  style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${record['date']} • ${record['time']}',
                  style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBgColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Zain',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
