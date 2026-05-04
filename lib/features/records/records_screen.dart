import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../shared/widgets/student_bottom_nav.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _selectedFilter = 'الكل';
  String _selectedPeriod = 'الشهر';
  int _visibleCount = 5;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.darkNavy,
      statusBarIconBrightness: Brightness.light,
    ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              // ── AppBar
              _RecordsAppBar(),

              // ── Stats Strip
              Container(
                color: AppColors.bgWhite,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _StatStrip(
                      label: 'إجمالي الحضور',
                      value: '${appState.attendancePercent}%',
                      subLabel: '+2% هذا الشهر',
                      subColor: AppColors.primary,
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _StatStrip(
                      label: 'أيام الغياب',
                      value: '${appState.absenceDays} أيام',
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    const _StatStrip(
                      label: 'التأخير',
                      value: '5 مرات',
                      valueColor: AppColors.statusLate,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Records List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header + filters
                      const Text(
                        'السجلات الحديثة',
                        style: TextStyle(
                          fontFamily: 'Zain',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FiltersRow(
                        selectedFilter: _selectedFilter,
                        selectedPeriod: _selectedPeriod,
                        onFilterChanged: (f) => setState(() => _selectedFilter = f),
                        onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
                      ),
                      const SizedBox(height: 14),

                      // Records
                      ...appState.records.take(_visibleCount).map(
                            (r) => _RecordCard(record: r),
                          ),

                      const SizedBox(height: 16),

                      // Load more button
                      GestureDetector(
                        onTap: () => setState(() => _visibleCount += 3),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.bgWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'عرض المزيد من السجلات',
                              style: TextStyle(
                                fontFamily: 'Zain',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const StudentBottomNav(
          currentIndex: 1,
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _RecordsAppBar extends StatelessWidget {
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fact_check_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'سجل الحضور',
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 18,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Strip ────────────────────────────────────────────────────────────────
class _StatStrip extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final Color? subColor;
  final Color? valueColor;

  const _StatStrip({
    required this.label,
    required this.value,
    this.subLabel,
    this.subColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Zain',
              fontSize: 15,
              color: AppColors.textMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textDark,
                ),
              ),
              if (subLabel != null)
                Text(
                  subLabel!,
                  style: TextStyle(
                    fontFamily: 'Zain',
                    fontSize: 11,
                    color: subColor ?? AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filters Row ───────────────────────────────────────────────────────────────
class _FiltersRow extends StatelessWidget {
  final String selectedFilter;
  final String selectedPeriod;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onPeriodChanged;

  const _FiltersRow({
    required this.selectedFilter,
    required this.selectedPeriod,
    required this.onFilterChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Filter dropdown
        Expanded(
          child: _DropdownChip(
            icon: Icons.filter_list_rounded,
            label: 'تصفية حسب $selectedFilter',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        // Period dropdown
        Expanded(
          child: _DropdownChip(
            icon: Icons.calendar_month_outlined,
            label: selectedPeriod,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DropdownChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.textMedium),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Zain',
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

// ── Record Card ───────────────────────────────────────────────────────────────
class _RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _RecordCard({required this.record});

  Color _statusColor(String s) {
    switch (s) {
      case 'حاضر': return AppColors.statusPresent;
      case 'غائب': return AppColors.statusAbsent;
      default: return AppColors.statusLate;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'حاضر': return AppColors.statusPresentBg;
      case 'غائب': return AppColors.statusAbsentBg;
      default: return AppColors.statusLateBg;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'حاضر': return Icons.check_circle_rounded;
      case 'غائب': return Icons.cancel_rounded;
      default: return Icons.watch_later_rounded;
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBg(status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Zain',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor(status),
              ),
            ),
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
                const SizedBox(height: 2),
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

          // Icon
          Icon(_statusIcon(status), color: _statusColor(status), size: 24),
        ],
      ),
    );
  }
}
