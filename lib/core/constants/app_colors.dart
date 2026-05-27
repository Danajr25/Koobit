import 'package:flutter/material.dart';

/// App color palette - Cartoony Kids Theme.
/// Bright, friendly colors suitable for a children's learning app.
/// All public names are intentionally kept identical to the previous cyber
/// palette so that the rest of the codebase swaps in transparently.
class AppColors {
  AppColors._();

  // Primary - Friendly Indigo / Purple
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7CF7);
  static const Color primaryDark = Color(0xFF4A3FBE);

  // Secondary - Warm Action Orange
  static const Color secondary = Color(0xFFFF8A3D);
  static const Color secondaryLight = Color(0xFFFFB07A);
  static const Color secondaryDark = Color(0xFFE66A1C);

  // Accent - Sunny Yellow
  static const Color accent = Color(0xFFFFCB45);
  static const Color accentLight = Color(0xFFFFE08A);
  static const Color accentDark = Color(0xFFE6A800);

  // Success - Bright Apple Green
  static const Color success = Color(0xFF4CD964);
  static const Color successLight = Color(0xFF7DE890);
  static const Color successDark = Color(0xFF2FAE48);

  // Error - Soft Strawberry
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF9B9B);
  static const Color errorDark = Color(0xFFD94A4A);

  // Warning - Tangerine
  static const Color warning = Color(0xFFFFB638);
  static const Color warningLight = Color(0xFFFFD175);
  static const Color warningDark = Color(0xFFE69412);

  // Gold / Star
  static const Color gold = Color(0xFFFFD33D);
  static const Color goldLight = Color(0xFFFFE57A);
  static const Color goldDark = Color(0xFFE6B800);

  // Backgrounds - Soft Cream / Lavender (LIGHT theme)
  static const Color background = Color(0xFFF7F5FF);
  static const Color backgroundDark = Color(0xFFEDE9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF1EEFB);

  // Text Colors - Friendly deep navy on light surfaces
  static const Color textPrimary = Color(0xFF2D2A5C);
  static const Color textSecondary = Color(0xFF7A7BA0);
  static const Color textLight = Color(0xFFB5B5D1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders - Soft Lavender
  static const Color border = Color(0xFFE4E0F5);
  static const Color borderLight = Color(0xFFF1EEFB);
  static const Color borderGlow = Color(0xFF8B7CF7);

  // Level Status Colors
  static const Color levelLocked = Color(0xFFCFCBE3);
  static const Color levelUnlocked = Color(0xFF6C5CE7);
  static const Color levelCompleted = Color(0xFF4CD964);
  static const Color levelInProgress = Color(0xFFFF8A3D);

  // Phase Colors - Bright cartoony rainbow
  static const List<Color> phaseColors = [
    Color(0xFFFF6B6B), // 1 - Coral
    Color(0xFFFF8A3D), // 2 - Orange
    Color(0xFFFFCB45), // 3 - Sunny Yellow
    Color(0xFF4CD964), // 4 - Apple Green
    Color(0xFF38C7E5), // 5 - Sky Blue
    Color(0xFF6C5CE7), // 6 - Friendly Purple
    Color(0xFFE56DD3), // 7 - Bubblegum Pink
    Color(0xFF20C5B0), // 8 - Mint Teal
    Color(0xFFFF7A7A), // 9 - Watermelon
    Color(0xFFA48BFF), // 10 - Lavender
    Color(0xFF6BD3A3), // 11 - Spring Green
    Color(0xFFFF9CC0), // 12 - Soft Pink
    Color(0xFF60B8FF), // 13 - Cornflower
  ];

  // Game Colors
  static const Color gameBackground = Color(0xFFE8F4FF);
  static const Color gamePlatform = Color(0xFF8B7CF7);

  // Worksheet Highlights - soft pastel tints
  static const Color correctHighlight = Color(0xFFE0F7E4);
  static const Color incorrectHighlight = Color(0xFFFFE0E0);
  static const Color currentQuestion = Color(0xFFEDE9FB);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sky hero gradient used behind home & headers.
  /// (Kept name `cyberGradient` so existing usages keep working.)
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF8B7CF7), Color(0xFF38C7E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Rainbow hero gradient. (Kept name `neonGradient`.)
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFE56DD3), Color(0xFFFF8A3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF8A3D), Color(0xFFFFCB45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
