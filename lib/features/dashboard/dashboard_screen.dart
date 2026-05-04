// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/router/app_router.dart';
import 'dashboard_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 768;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: FadeTransition(
          opacity: _fade,
          child: isWide
              ? _WideLayout(appState: appState)
              : _NarrowLayout(appState: appState),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Wide Layout
// ══════════════════════════════════════════════════════════════════════════════
class _WideLayout extends StatelessWidget {
  final AppState appState;
  const _WideLayout({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Sidebar(appState: appState),
        Expanded(
          child: Column(
            children: [
              _TopBar(appState: appState),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // ✅ FIX: pass instructorId
                      _KpiRow(instructorId: appState.currentUserId ?? ''),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                _WeeklyChartCard(appState: appState),
                                const SizedBox(height: 16),
                                const _DeviceStatusCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: _AttendanceTableCard()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Narrow Layout
// ══════════════════════════════════════════════════════════════════════════════
class _NarrowLayout extends StatelessWidget {
  final AppState appState;
  const _NarrowLayout({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileTopBar(appState: appState),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ FIX: pass instructorId
                _KpiRow(instructorId: appState.currentUserId ?? ''),
                const SizedBox(height: 16),
                _WeeklyChartCard(appState: appState),
                const SizedBox(height: 16),
                const _AttendanceTableCard(),
                const SizedBox(height: 16),
                const _DeviceStatusCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final AppState appState;
  const _Sidebar({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.bgWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
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
                  const Flexible(
                    child: Text(
                      '6OTU Attendance',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Admin',
                            style: TextStyle(
                              fontFamily: 'Zain',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '6OTU Supervisor',
                            style: TextStyle(
                              fontFamily: 'Zain',
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SideNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isActive: true),
            _SideNavItem(
                icon: Icons.people_alt_rounded,
                label: 'Student Directory',
                isActive: false),
            _SideNavItem(
                icon: Icons.assessment_outlined,
                label: 'System Reports',
                isActive: false),
            _SideNavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isActive: false),
            _SideNavItem(
                icon: Icons.nfc_rounded,
                label: 'RFID Monitor',
                isActive: false,
                onTap: () => context.go(AppRouter.rfidMonitor)),
            const Spacer(),
            const Divider(color: AppColors.divider),
            InkWell(
              onTap: () {
                AppState.instance.logout();
                context.go(AppRouter.login);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.alertDanger, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 14,
                        color: AppColors.alertDanger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SideNavItem(
      {required this.icon,
      required this.label,
      required this.isActive,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            size: 20,
            color: isActive ? AppColors.primary : AppColors.textLight),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Zain',
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap ?? () {},
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppState appState;
  const _TopBar({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لوحة تحكم المشرف',
                    style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'مرحباً بك في جامعة 6 أكتوبر التكنولوجية',
                    style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded,
                    color: AppColors.textMedium),
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textMedium),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.alertDanger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile Top Bar ────────────────────────────────────────────────────────────
class _MobileTopBar extends StatelessWidget {
  final AppState appState;
  const _MobileTopBar({required this.appState});

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
              Container(
                width: 34,
                height: 34,
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة تحكم المشرف',
                    style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    'Academic Admin',
                    style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded,
                    color: AppColors.textWhite),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textWhite),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.alertDanger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── KPI Row ✅ FIXED ──────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  // ✅ FIX: added instructorId parameter
  final String instructorId;
  const _KpiRow({required this.instructorId});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    final cards = [
      StreamBuilder<int>(
        // ✅ FIX: pass instructorId
        stream: DashboardService.totalStudentsStream(instructorId),
        builder: (context, snap) => _KpiCard(
          data: _KpiData(
            title: 'إجمالي الطلاب',
            value: '${snap.data ?? 0}',
            sub: 'مسجلين في النظام',
            subColor: AppColors.primary,
            icon: Icons.people_alt_rounded,
            iconBg: AppColors.primary.withValues(alpha: 0.12),
            iconColor: AppColors.primary,
          ),
        ),
      ),
      StreamBuilder<int>(
        // ✅ FIX: pass instructorId
        stream: DashboardService.presentTodayStream(instructorId),
        builder: (context, snap) => _KpiCard(
          data: _KpiData(
            title: 'حاضر الآن',
            value: '${snap.data ?? 0}',
            sub: 'مباشر',
            subColor: AppColors.primary,
            icon: Icons.sensors_rounded,
            iconBg: AppColors.primary.withValues(alpha: 0.12),
            iconColor: AppColors.primary,
            showTag: true,
            tagLabel: 'مباشر',
          ),
        ),
      ),
      StreamBuilder<int>(
        // ✅ FIX: pass instructorId
        stream: DashboardService.absentTodayStream(instructorId),
        builder: (context, snap) => _KpiCard(
          data: _KpiData(
            title: 'غائب',
            value: '${snap.data ?? 0}',
            sub: 'اليوم',
            subColor: AppColors.statusAbsent,
            icon: Icons.person_off_rounded,
            iconBg: AppColors.statusAbsentBg,
            iconColor: AppColors.statusAbsent,
          ),
        ),
      ),
      StreamBuilder<int>(
        stream: DashboardService.criticalAlertsStream(),
        builder: (context, snap) => _KpiCard(
          data: _KpiData(
            title: 'تنبيهات حرجة',
            value: '${snap.data ?? 0}',
            sub: 'مطلوب مراجعة فورية',
            subColor: AppColors.alertWarning,
            icon: Icons.warning_amber_rounded,
            iconBg: AppColors.alertWarningBg,
            iconColor: AppColors.alertWarning,
            isDark: true,
          ),
        ),
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 12), child: c),
                ))
            .toList(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: cards,
    );
  }
}

class _KpiData {
  final String title, value, sub;
  final Color subColor, iconBg, iconColor;
  final IconData icon;
  final bool isDark, isBig, showTag;
  final String? tagLabel;

  const _KpiData({
    required this.title,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isDark = false,
    // ignore: unused_element_parameter
    this.isBig = false,
    this.showTag = false,
    this.tagLabel,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final bg = data.isDark ? AppColors.darkNavy : AppColors.bgWhite;
    final titleColor = data.isDark ? AppColors.textWhite : AppColors.textMedium;
    final valueColor = data.isDark ? AppColors.primary : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isDark ? Colors.transparent : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 18),
              ),
              const Spacer(),
              if (data.showTag && data.tagLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.tagLabel!,
                    style: const TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.title,
              style: TextStyle(
                  fontFamily: 'Zain', fontSize: 12, color: titleColor)),
          const SizedBox(height: 2),
          Text(data.value,
              style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: valueColor)),
          const SizedBox(height: 4),
          Text(data.sub,
              style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 11,
                  color: data.subColor,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  final AppState appState;
  const _WeeklyChartCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final days = ['أحد', 'اثن', 'ثلاء', 'أربعاء', 'خميس'];
    final data = appState.weeklyData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('اتجاهات الحضور الأسبوعية',
              style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: AppColors.chartGrid, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox();
                        }
                        return Text(days[idx],
                            style: const TextStyle(
                                fontFamily: 'Zain',
                                fontSize: 10,
                                color: AppColors.textGrey));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.take(5).length,
                        (i) => FlSpot(i.toDouble(), data[i])),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.bgWhite,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 60,
                maxY: 100,
              ),
              duration: const Duration(milliseconds: 800),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('متوسط الحضور',
                  style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 11,
                      color: AppColors.textGrey)),
              SizedBox(width: 6),
              Text('80–85%',
                  style: TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceTableCard extends StatefulWidget {
  const _AttendanceTableCard();

  @override
  State<_AttendanceTableCard> createState() => _AttendanceTableCardState();
}

class _AttendanceTableCardState extends State<_AttendanceTableCard> {
  bool _showAll = false;

  Future<void> _exportPdf(List<Map<String, dynamic>> rows) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _showAll ? 'قائمة جميع الطلاب' : 'سجل حضور المحاضرة',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'تاريخ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('اسم الطالب',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('رقم القيد',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('وقت المسح',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('الحالة',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...rows.map((row) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(row['name'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(row['id'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(row['rfidTime'] ?? '--'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(row['status'] ?? ''),
                          ),
                        ],
                      )),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('إجمالي: ${rows.length} طالب',
                  style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: _showAll
          ? 'all_students.pdf'
          : 'attendance_${DateTime.now().day}_${DateTime.now().month}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final instructorId = AppState.instance.currentUserId ?? '';

    final stream = _showAll
        ? DashboardService.allStudentsStream(instructorId)
        : DashboardService.attendanceStream(instructorId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          final rows = snap.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _showAll ? 'جميع الطلاب' : 'حضور المحاضرة الحالية',
                    style: const TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showAll = !_showAll),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showAll
                                ? Icons.list_alt_rounded
                                : Icons.people_alt_rounded,
                            size: 14,
                            color: AppColors.textMedium,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _showAll ? 'حضور اليوم' : 'كل الطلاب',
                            style: const TextStyle(
                                fontFamily: 'Zain',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: rows.isEmpty ? null : () => _exportPdf(rows),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.picture_as_pdf_rounded,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 5),
                          Text('تقرير PDF',
                              style: TextStyle(
                                  fontFamily: 'Zain',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('اسم الطالب',
                            style: _tableHeaderStyle,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text('رقم القيد',
                            style: _tableHeaderStyle,
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 2,
                        child: Text('وقت المسح RFID',
                            style: _tableHeaderStyle,
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 2,
                        child: Text('الحالة',
                            style: _tableHeaderStyle,
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 1,
                        child: Text('إجراءات',
                            style: _tableHeaderStyle,
                            textAlign: TextAlign.center)),
                  ],
                ),
              ),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('لا يوجد بيانات',
                        style: TextStyle(
                            fontFamily: 'Zain', color: AppColors.textLight)),
                  ),
                )
              else
                Column(
                  children: rows.map((row) => _TableRow(data: row)).toList(),
                ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'إجمالي: ${rows.length} طالب',
                  style: const TextStyle(
                      fontFamily: 'Zain',
                      fontSize: 13,
                      color: AppColors.textMedium),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const _tableHeaderStyle = TextStyle(
  fontFamily: 'Zain',
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: AppColors.textLight,
);

class _TableRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TableRow({required this.data});

  Color _statusColor(String s) {
    switch (s) {
      case 'حاضر':
        return AppColors.statusPresent;
      case 'غائب':
        return AppColors.statusAbsent;
      default:
        return AppColors.statusLate;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'حاضر':
        return AppColors.statusPresentBg;
      case 'غائب':
        return AppColors.statusAbsentBg;
      default:
        return AppColors.statusLateBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'غائب';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      (data['avatarColor'] as Color).withValues(alpha: 0.2),
                  child: Icon(Icons.person,
                      color: data['avatarColor'] as Color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(data['id'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 12,
                    color: AppColors.textMedium)),
          ),
          Expanded(
            flex: 2,
            child: Text(data['rfidTime'] ?? '--',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 12,
                    color: AppColors.textMedium)),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(status))),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textGrey, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _TableActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    // ignore: unused_element_parameter
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.bgLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color: isPrimary ? AppColors.primary : AppColors.textMedium),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isPrimary ? AppColors.primary : AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

// ── Device Status Card ────────────────────────────────────────────────────────
class _DeviceStatusCard extends StatelessWidget {
  const _DeviceStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('حالة أجهزة الاستشعار',
              style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite)),
          const SizedBox(height: 14),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DashboardService.devicesStream(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) {
                return const Text('لا توجد أجهزة',
                    style: TextStyle(
                        fontFamily: 'Zain', color: AppColors.textGrey));
              }
              return Column(
                children: snap.data!.map((d) => _DeviceRow(device: d)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final Map<String, dynamic> device;
  const _DeviceRow({required this.device});

  @override
  Widget build(BuildContext context) {
    final isConnected = device['connected'] as bool? ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? AppColors.connected : AppColors.disconnected,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(device['name'] ?? '',
                style: const TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 13,
                    color: AppColors.textGrey)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:
                  (isConnected ? AppColors.connected : AppColors.disconnected)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isConnected ? 'متصل' : 'غير متصل',
              style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isConnected
                      ? AppColors.connected
                      : AppColors.disconnected),
            ),
          ),
        ],
      ),
    );
  }
}
