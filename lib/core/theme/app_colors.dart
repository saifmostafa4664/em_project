import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFFAACC00);        // Lime Green - main accent
  static const Color primaryDark = Color(0xFF7A9900);    // Darker lime
  static const Color primaryLight = Color(0xFFD4F04A);   // Light lime

  // Dark Navy (Splash / dark cards)
  static const Color darkNavy = Color(0xFF1B2341);
  static const Color darkNavyLight = Color(0xFF243057);
  static const Color darkNavyCard = Color(0xFF1E2A4A);

  // Backgrounds
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF5F6FA);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardAlt = Color(0xFFF8F9FC);

  // Text Colors
  static const Color textDark = Color(0xFF1B2341);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF8A94A6);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9AA5B4);

  // Status Colors
  static const Color statusPresent = Color(0xFFAACC00);   // حاضر
  static const Color statusPresentBg = Color(0xFFEEF7C8);
  static const Color statusAbsent = Color(0xFFE53935);    // غائب
  static const Color statusAbsentBg = Color(0xFFFFEBEB);
  static const Color statusLate = Color(0xFFFF9800);      // متأخر
  static const Color statusLateBg = Color(0xFFFFF3E0);

  // Alert / Warning
  static const Color alertWarning = Color(0xFFFF9800);
  static const Color alertWarningBg = Color(0xFFFFF8E1);
  static const Color alertDanger = Color(0xFFE53935);
  static const Color alertDangerBg = Color(0xFFFFEBEB);

  // Divider & Border
  static const Color border = Color(0xFFE8ECF4);
  static const Color divider = Color(0xFFF0F2F8);

  // Shadow
  static const Color shadow = Color(0x0A1B2341);
  static const Color shadowMedium = Color(0x141B2341);

  // Nav Bar
  static const Color navInactive = Color(0xFF8A94A6);
  static const Color navActive = primary;

  // Chart Colors
  static const Color chartLine = primary;
  static const Color chartGrid = Color(0xFFECEFF4);

  // Connected / Disconnected
  static const Color connected = Color(0xFF4CAF50);
  static const Color disconnected = Color(0xFFE53935);
}
