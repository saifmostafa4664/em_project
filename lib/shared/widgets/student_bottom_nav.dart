import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const StudentBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navIndex = currentIndex;

    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'الرئيسية', route: AppRouter.home),
      _NavItem(icon: Icons.fact_check_rounded, label: 'السجلات', route: AppRouter.records),
      _NavItem(icon: Icons.calendar_month_rounded, label: 'الجدول', route: null),
      _NavItem(icon: Icons.person_rounded, label: 'الملف', route: null),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == navIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap!(i);
                    }
                    if (item.route != null) {
                      context.go(item.route!);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.navInactive,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Zain',
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.navInactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String? route;
  _NavItem({required this.icon, required this.label, this.route});
}
