import 'package:flutter/material.dart';

/// App color palette - Cyber Futuristic Theme
class AppColors {
  AppColors._();

  // Primary Colors - Neon Cyan
  static const Color primary = Color(0xFF00D4FF);       // Neon Cyan
  static const Color primaryLight = Color(0xFF4DE8FF);
  static const Color primaryDark = Color(0xFF00A8CC);

  // Secondary Colors - Neon Orange/Amber
  static const Color secondary = Color(0xFFFF9500);     // Neon Orange
  static const Color secondaryLight = Color(0xFFFFB347);
  static const Color secondaryDark = Color(0xFFE68600);

  // Accent Colors - Neon Purple
  static const Color accent = Color(0xFFBF5AF2);        // Neon Purple
  static const Color accentLight = Color(0xFFD98FFF);
  static const Color accentDark = Color(0xFF9B37D9);

  // Success/Correct - Neon Green
  static const Color success = Color(0xFF00FF88);       // Neon Green
  static const Color successLight = Color(0xFF66FFB3);
  static const Color successDark = Color(0xFF00CC6A);

  // Error/Wrong - Neon Red
  static const Color error = Color(0xFFFF3B5C);         // Neon Red/Pink
  static const Color errorLight = Color(0xFFFF6B85);
  static const Color errorDark = Color(0xFFD32F4A);

  // Warning - Neon Yellow
  static const Color warning = Color(0xFFFFE600);       // Neon Yellow
  static const Color warningLight = Color(0xFFFFF066);
  static const Color warningDark = Color(0xFFCCB800);

  // Star/Gold - Neon Gold
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE54C);
  static const Color goldDark = Color(0xFFFFC107);

  // Backgrounds - Dark Navy
  static const Color background = Color(0xFF0A0E27);    // Deep Navy
  static const Color backgroundDark = Color(0xFF060818);
  static const Color surface = Color(0xFF131836);       // Slightly lighter navy
  static const Color surfaceDark = Color(0xFF1A2142);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);   // White
  static const Color textSecondary = Color(0xFF8B9DC3); // Muted blue-gray
  static const Color textLight = Color(0xFF5A6B8C);
  static const Color textOnPrimary = Color(0xFF0A0E27); // Dark for contrast

  // Border Colors - Glowing Cyan
  static const Color border = Color(0xFF1E3A5F);        // Dark blue border
  static const Color borderLight = Color(0xFF2A4A70);
  static const Color borderGlow = Color(0xFF00D4FF);    // Cyan glow

  // Level Status Colors
  static const Color levelLocked = Color(0xFF3D4A6B);   // Muted navy
  static const Color levelUnlocked = Color(0xFF00D4FF); // Cyan
  static const Color levelCompleted = Color(0xFF00FF88);// Neon green
  static const Color levelInProgress = Color(0xFFFF9500);// Orange

  // Phase Colors (for visual distinction) - Neon palette
  static const List<Color> phaseColors = [
    Color(0xFFFF3B5C),  // Phase 1 - Neon Red
    Color(0xFFFF9500),  // Phase 2 - Neon Orange
    Color(0xFFFFE600),  // Phase 3 - Neon Yellow
    Color(0xFF00FF88),  // Phase 4 - Neon Green
    Color(0xFF00D4FF),  // Phase 5 - Neon Cyan
    Color(0xFFBF5AF2),  // Phase 6 - Neon Purple
    Color(0xFFFF6FF4),  // Phase 7 - Neon Pink
    Color(0xFF00FFD4),  // Phase 8 - Neon Teal
    Color(0xFFFF6B35),  // Phase 9 - Neon Deep Orange
    Color(0xFF8B5CF6),  // Phase 10 - Neon Violet
    Color(0xFF00FFAA),  // Phase 11 - Neon Mint
    Color(0xFFFF4D6D),  // Phase 12 - Neon Coral
  ];

  // Game Colors - Cyber theme
  static const Color gameBackground = Color(0xFF0A0E27); // Dark navy
  static const Color gamePlatform = Color(0xFF1A2142);   // Surface color

  // Worksheet Colors - Dark theme
  static const Color correctHighlight = Color(0xFF0D3320);  // Dark green
  static const Color incorrectHighlight = Color(0xFF3D1520);// Dark red
  static const Color currentQuestion = Color(0xFF0D2840);   // Dark cyan

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successDark, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // New Cyber gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF131836)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFFBF5AF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9500), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
