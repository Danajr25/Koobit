import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Level configuration for the math learning app
/// Contains all 54+ levels across 12 phases

/// Represents a learning phase containing multiple levels
class LearningPhase {
  final int phaseNumber;
  final String nameEn;
  final String nameMs;
  final Color color;
  final List<LevelConfig> levels;

  LearningPhase({
    required this.phaseNumber,
    required this.nameEn,
    required this.nameMs,
    required this.color,
    required this.levels,
  });

  String getName(String languageCode) {
    return languageCode == 'ms' ? nameMs : nameEn;
  }
}

/// Represents a single level's configuration
class LevelConfig {
  final int level;
  final String topicEn;
  final String topicMs;
  final String descriptionEn;
  final String descriptionMs;
  final LevelType type;
  final int questionsPerWorksheet;
  final int timeMinutes;
  final double passPercentage;
  /// Number of pages (sub-worksheets) in this level. Each page focuses on one
  /// progressive operand (e.g. page 1 = +1, page 2 = +2). Default 10.
  final int pages;

  LevelConfig({
    required this.level,
    required this.topicEn,
    required this.topicMs,
    required this.descriptionEn,
    required this.descriptionMs,
    required this.type,
    this.questionsPerWorksheet = 50,
    this.timeMinutes = 10,
    this.passPercentage = 0.95,
    this.pages = 5,
  });

  String getTopic(String languageCode) {
    return languageCode == 'ms' ? topicMs : topicEn;
  }

  String getDescription(String languageCode) {
    return languageCode == 'ms' ? descriptionMs : descriptionEn;
  }
}

/// Types of levels/questions
enum LevelType {
  tracing,
  numberWriting,
  sequences,
  addition,
  subtraction,
  multiplication,
  division,
  fractions,
  algebra,
  signedNumbers,
  inequalities,
  powers,
  roots,
  monomials,
  polynomials,
  factorization,
  quadratic,
  pythagorean,
}

/// All learning phases with their levels
class LevelConfiguration {
  LevelConfiguration._();

  static final List<LearningPhase> phases = [
    // Phase 1: Hand Coordination & Number Recognition
    LearningPhase(
      phaseNumber: 1,
      nameEn: 'Hand Coordination',
      nameMs: 'Koordinasi Tangan',
      color: AppColors.phaseColors[0],
      levels: [
        LevelConfig(
          level: 1,
          topicEn: 'Line Tracing',
          topicMs: 'Mengesan Garisan',
          descriptionEn: 'Connect dots using straight lines',
          descriptionMs: 'Sambungkan titik menggunakan garisan lurus',
          type: LevelType.tracing,
        ),
        LevelConfig(
          level: 2,
          topicEn: 'Curve Tracing',
          topicMs: 'Mengesan Lengkungan',
          descriptionEn: 'Connect dots using curved lines',
          descriptionMs: 'Sambungkan titik menggunakan garisan lengkung',
          type: LevelType.tracing,
        ),
        LevelConfig(
          level: 3,
          topicEn: 'Number Tracing (1-10)',
          topicMs: 'Mengesan Nombor (1-10)',
          descriptionEn: 'Trace numbers using dotted guides',
          descriptionMs: 'Ikut nombor menggunakan panduan bertitik',
          type: LevelType.tracing,
        ),
        LevelConfig(
          level: 4,
          topicEn: 'Number Writing (1-10)',
          topicMs: 'Menulis Nombor (1-10)',
          descriptionEn: 'Write numbers without guides',
          descriptionMs: 'Tulis nombor tanpa panduan',
          type: LevelType.numberWriting,
        ),
        LevelConfig(
          level: 5,
          topicEn: 'Number Tracing (11-50)',
          topicMs: 'Mengesan Nombor (11-50)',
          descriptionEn: 'Trace two-digit numbers',
          descriptionMs: 'Ikut nombor dua digit',
          type: LevelType.tracing,
        ),
        LevelConfig(
          level: 6,
          topicEn: 'Number Writing (11-50)',
          topicMs: 'Menulis Nombor (11-50)',
          descriptionEn: 'Write numbers independently',
          descriptionMs: 'Tulis nombor secara bebas',
          type: LevelType.numberWriting,
        ),
        LevelConfig(
          level: 7,
          topicEn: 'Number Tracing (51-100)',
          topicMs: 'Mengesan Nombor (51-100)',
          descriptionEn: 'Trace larger numbers',
          descriptionMs: 'Ikut nombor yang lebih besar',
          type: LevelType.tracing,
        ),
        LevelConfig(
          level: 8,
          topicEn: 'Number Writing (51-100)',
          topicMs: 'Menulis Nombor (51-100)',
          descriptionEn: 'Write numbers independently',
          descriptionMs: 'Tulis nombor secara bebas',
          type: LevelType.numberWriting,
        ),
      ],
    ),

    // Phase 2: Number Sequences
    LearningPhase(
      phaseNumber: 2,
      nameEn: 'Number Sequences',
      nameMs: 'Jujukan Nombor',
      color: AppColors.phaseColors[1],
      levels: [
        LevelConfig(
          level: 9,
          topicEn: 'Counting & Sequences',
          topicMs: 'Mengira & Jujukan',
          descriptionEn: 'Fill in missing numbers',
          descriptionMs: 'Isi nombor yang hilang',
          type: LevelType.sequences,
        ),
      ],
    ),

    // Phase 3: Addition
    LearningPhase(
      phaseNumber: 3,
      nameEn: 'Addition',
      nameMs: 'Penambahan',
      color: AppColors.phaseColors[2],
      levels: [
        LevelConfig(
          level: 10,
          topicEn: 'Addition (+1, +2)',
          topicMs: 'Tambah (+1, +2)',
          descriptionEn: 'Single-digit addition basics',
          descriptionMs: 'Asas penambahan satu digit',
          type: LevelType.addition,
          pages: 5,
        ),
        LevelConfig(
          level: 11,
          topicEn: 'Addition (+3 to +5)',
          topicMs: 'Tambah (+3 hingga +5)',
          descriptionEn: 'Single-digit addition',
          descriptionMs: 'Penambahan satu digit',
          type: LevelType.addition,
          pages: 5,
        ),
        LevelConfig(
          level: 12,
          topicEn: 'Addition (+6 to +9)',
          topicMs: 'Tambah (+6 hingga +9)',
          descriptionEn: 'Single-digit addition',
          descriptionMs: 'Penambahan satu digit',
          type: LevelType.addition,
          pages: 5,
        ),
        LevelConfig(
          level: 13,
          topicEn: 'Addition (2-digit)',
          topicMs: 'Tambah (2 digit)',
          descriptionEn: 'Two-digit addition',
          descriptionMs: 'Penambahan dua digit',
          type: LevelType.addition,
          pages: 5,
        ),
      ],
    ),

    // Phase 4: Subtraction
    LearningPhase(
      phaseNumber: 4,
      nameEn: 'Subtraction',
      nameMs: 'Penolakan',
      color: AppColors.phaseColors[3],
      levels: [
        LevelConfig(
          level: 14,
          topicEn: 'Subtraction (-1 to -5)',
          topicMs: 'Tolak (-1 hingga -5)',
          descriptionEn: 'Single-digit subtraction',
          descriptionMs: 'Penolakan satu digit',
          type: LevelType.subtraction,
          pages: 5,
        ),
        LevelConfig(
          level: 15,
          topicEn: 'Subtraction (-6 to -9)',
          topicMs: 'Tolak (-6 hingga -9)',
          descriptionEn: 'Larger single-digit subtraction',
          descriptionMs: 'Penolakan satu digit yang lebih besar',
          type: LevelType.subtraction,
          pages: 5,
        ),
        LevelConfig(
          level: 16,
          topicEn: 'Subtraction (2-digit)',
          topicMs: 'Tolak (2 digit)',
          descriptionEn: 'Two-digit subtraction',
          descriptionMs: 'Penolakan dua digit',
          type: LevelType.subtraction,
          pages: 5,
        ),
      ],
    ),

    // Phase 5: Multiplication
    LearningPhase(
      phaseNumber: 5,
      nameEn: 'Multiplication',
      nameMs: 'Pendaraban',
      color: AppColors.phaseColors[4],
      levels: [
        LevelConfig(
          level: 17,
          topicEn: 'Multiplication (×1 to ×5)',
          topicMs: 'Darab (×1 hingga ×5)',
          descriptionEn: 'Basic multiplication tables',
          descriptionMs: 'Jadual pendaraban asas',
          type: LevelType.multiplication,
          pages: 5,
        ),
        LevelConfig(
          level: 18,
          topicEn: 'Multiplication (×6 to ×12)',
          topicMs: 'Darab (×6 hingga ×12)',
          descriptionEn: 'Advanced multiplication tables',
          descriptionMs: 'Jadual pendaraban lanjutan',
          type: LevelType.multiplication,
          pages: 5,
        ),
      ],
    ),

    // Phase 6: Division
    LearningPhase(
      phaseNumber: 6,
      nameEn: 'Division',
      nameMs: 'Pembahagian',
      color: AppColors.phaseColors[5],
      levels: [
        LevelConfig(
          level: 19,
          topicEn: 'Division (÷1 to ÷5)',
          topicMs: 'Bahagi (÷1 hingga ÷5)',
          descriptionEn: 'Basic division',
          descriptionMs: 'Pembahagian asas',
          type: LevelType.division,
          pages: 5,
        ),
        LevelConfig(
          level: 20,
          topicEn: 'Division (÷6 to ÷12)',
          topicMs: 'Bahagi (÷6 hingga ÷12)',
          descriptionEn: 'Advanced division',
          descriptionMs: 'Pembahagian lanjutan',
          type: LevelType.division,
          pages: 5,
        ),
      ],
    ),

    // Phase 7: Fractions
    LearningPhase(
      phaseNumber: 7,
      nameEn: 'Fractions',
      nameMs: 'Pecahan',
      color: AppColors.phaseColors[6],
      levels: [
        LevelConfig(
          level: 21,
          topicEn: 'Fractions Basics',
          topicMs: 'Asas Pecahan',
          descriptionEn: 'Recognize and write basic fractions',
          descriptionMs: 'Kenal dan tulis pecahan asas',
          type: LevelType.fractions,
        ),
        LevelConfig(
          level: 22,
          topicEn: 'Fraction Operations',
          topicMs: 'Operasi Pecahan',
          descriptionEn: 'Comprehensive fraction work',
          descriptionMs: 'Kerja pecahan menyeluruh',
          type: LevelType.fractions,
        ),
      ],
    ),

    // Phase 8: Pre-Algebra
    LearningPhase(
      phaseNumber: 8,
      nameEn: 'Pre-Algebra',
      nameMs: 'Pra-Algebra',
      color: AppColors.phaseColors[7],
      levels: [
        LevelConfig(
          level: 23,
          topicEn: 'Intro to Variables',
          topicMs: 'Pengenalan Pembolehubah',
          descriptionEn: 'Learn method equations',
          descriptionMs: 'Belajar persamaan kaedah',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 24,
          topicEn: 'Linear Equations (Basic)',
          topicMs: 'Persamaan Linear (Asas)',
          descriptionEn: 'One-step equations',
          descriptionMs: 'Persamaan satu langkah',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 25,
          topicEn: 'Linear Equations (Advanced)',
          topicMs: 'Persamaan Linear (Lanjutan)',
          descriptionEn: 'Multi-step equations',
          descriptionMs: 'Persamaan berbilang langkah',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 26,
          topicEn: 'Variables on Both Sides',
          topicMs: 'Pembolehubah di Kedua Sisi',
          descriptionEn: 'Move variables to one side',
          descriptionMs: 'Alih pembolehubah ke satu sisi',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 27,
          topicEn: 'Equations with Brackets',
          topicMs: 'Persamaan dengan Kurungan',
          descriptionEn: 'Distributive Law',
          descriptionMs: 'Hukum Taburan',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 28,
          topicEn: 'Equations with Fractions',
          topicMs: 'Persamaan dengan Pecahan',
          descriptionEn: 'Clearing fractions using LCM',
          descriptionMs: 'Menghapuskan pecahan menggunakan GSTK',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 29,
          topicEn: 'Negative Coefficients',
          topicMs: 'Pekali Negatif',
          descriptionEn: 'Handle negative coefficients',
          descriptionMs: 'Kendalikan pekali negatif',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 30,
          topicEn: 'Literal Equations',
          topicMs: 'Persamaan Literal',
          descriptionEn: 'Two or more variables',
          descriptionMs: 'Dua atau lebih pembolehubah',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 31,
          topicEn: 'Simultaneous Equations (2 var)',
          topicMs: 'Persamaan Serentak (2 pembolehubah)',
          descriptionEn: 'Elimination methods',
          descriptionMs: 'Kaedah penghapusan',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 32,
          topicEn: 'Simultaneous Equations (3-4 var)',
          topicMs: 'Persamaan Serentak (3-4 pembolehubah)',
          descriptionEn: 'Extended simultaneous equations',
          descriptionMs: 'Persamaan serentak lanjutan',
          type: LevelType.algebra,
        ),
        LevelConfig(
          level: 33,
          topicEn: 'Signed Numbers (+/-)',
          topicMs: 'Nombor Bertanda (+/-)',
          descriptionEn: 'Addition/Subtraction of signed numbers',
          descriptionMs: 'Tambah/Tolak nombor bertanda',
          type: LevelType.signedNumbers,
        ),
        LevelConfig(
          level: 34,
          topicEn: 'Signed Multiplication',
          topicMs: 'Pendaraban Bertanda',
          descriptionEn: 'Multiplication of +ve and -ve numbers',
          descriptionMs: 'Pendaraban nombor +ve dan -ve',
          type: LevelType.signedNumbers,
        ),
        LevelConfig(
          level: 35,
          topicEn: 'Signed Division',
          topicMs: 'Pembahagian Bertanda',
          descriptionEn: 'Division of +ve and -ve numbers',
          descriptionMs: 'Pembahagian nombor +ve dan -ve',
          type: LevelType.signedNumbers,
        ),
        LevelConfig(
          level: 36,
          topicEn: 'Four Operations (Signed)',
          topicMs: 'Empat Operasi (Bertanda)',
          descriptionEn: 'Combined operations with signed numbers',
          descriptionMs: 'Operasi gabungan dengan nombor bertanda',
          type: LevelType.signedNumbers,
        ),
        LevelConfig(
          level: 37,
          topicEn: 'Inequalities',
          topicMs: 'Ketaksamaan',
          descriptionEn: 'Compare values (>, <)',
          descriptionMs: 'Bandingkan nilai (>, <)',
          type: LevelType.inequalities,
        ),
      ],
    ),

    // Phase 9: Powers & Roots
    LearningPhase(
      phaseNumber: 9,
      nameEn: 'Powers & Roots',
      nameMs: 'Kuasa & Punca',
      color: AppColors.phaseColors[8],
      levels: [
        LevelConfig(
          level: 38,
          topicEn: 'Powers of 2',
          topicMs: 'Kuasa 2',
          descriptionEn: 'Square/power basics',
          descriptionMs: 'Asas kuasa dua',
          type: LevelType.powers,
        ),
        LevelConfig(
          level: 39,
          topicEn: 'Square Roots',
          topicMs: 'Punca Kuasa Dua',
          descriptionEn: 'Square root basics',
          descriptionMs: 'Asas punca kuasa dua',
          type: LevelType.roots,
        ),
        LevelConfig(
          level: 40,
          topicEn: 'Cubic/Power of 3',
          topicMs: 'Kuasa 3',
          descriptionEn: 'Cube basics',
          descriptionMs: 'Asas kuasa tiga',
          type: LevelType.powers,
        ),
        LevelConfig(
          level: 41,
          topicEn: 'Cube Root',
          topicMs: 'Punca Kuasa Tiga',
          descriptionEn: 'Cube root basics',
          descriptionMs: 'Asas punca kuasa tiga',
          type: LevelType.roots,
        ),
        LevelConfig(
          level: 42,
          topicEn: 'Indices',
          topicMs: 'Indeks',
          descriptionEn: 'Index laws',
          descriptionMs: 'Hukum indeks',
          type: LevelType.powers,
        ),
      ],
    ),

    // Phase 10: Monomials & Polynomials
    LearningPhase(
      phaseNumber: 10,
      nameEn: 'Monomials & Polynomials',
      nameMs: 'Monomial & Polinomial',
      color: AppColors.phaseColors[9],
      levels: [
        LevelConfig(
          level: 43,
          topicEn: 'Monomials',
          topicMs: 'Monomial',
          descriptionEn: 'Monomial operations',
          descriptionMs: 'Operasi monomial',
          type: LevelType.monomials,
        ),
        LevelConfig(
          level: 44,
          topicEn: 'Polynomials',
          topicMs: 'Polinomial',
          descriptionEn: 'Polynomial operations',
          descriptionMs: 'Operasi polinomial',
          type: LevelType.polynomials,
        ),
        LevelConfig(
          level: 45,
          topicEn: 'Multiplication Formulas',
          topicMs: 'Formula Pendaraban',
          descriptionEn: 'Three key formulas',
          descriptionMs: 'Tiga formula utama',
          type: LevelType.polynomials,
        ),
      ],
    ),

    // Phase 11: Factorization
    LearningPhase(
      phaseNumber: 11,
      nameEn: 'Factorization',
      nameMs: 'Pemfaktoran',
      color: AppColors.phaseColors[10],
      levels: [
        LevelConfig(
          level: 46,
          topicEn: 'Greatest Common Factor',
          topicMs: 'Faktor Sepunya Terbesar',
          descriptionEn: 'GCF extraction',
          descriptionMs: 'Pengekstrakan FST',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 47,
          topicEn: 'Simple Trinomials',
          topicMs: 'Trinomial Mudah',
          descriptionEn: 'ax² + bx + c where a=1',
          descriptionMs: 'ax² + bx + c di mana a=1',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 48,
          topicEn: 'Advanced Trinomials',
          topicMs: 'Trinomial Lanjutan',
          descriptionEn: 'ax² + bx + c where a≠1',
          descriptionMs: 'ax² + bx + c di mana a≠1',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 49,
          topicEn: 'Difference of Squares',
          topicMs: 'Beza Kuasa Dua',
          descriptionEn: 'a² - b² formula',
          descriptionMs: 'Formula a² - b²',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 50,
          topicEn: 'Perfect Square Trinomial',
          topicMs: 'Trinomial Kuasa Dua Sempurna',
          descriptionEn: 'Formula application',
          descriptionMs: 'Aplikasi formula',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 51,
          topicEn: 'Sum/Difference of Cubes',
          topicMs: 'Jumlah/Beza Kuasa Tiga',
          descriptionEn: 'Cube formulas',
          descriptionMs: 'Formula kuasa tiga',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 52,
          topicEn: 'Factorize by Grouping',
          topicMs: 'Pemfaktoran Berkumpulan',
          descriptionEn: '4-term polynomials',
          descriptionMs: 'Polinomial 4 sebutan',
          type: LevelType.factorization,
        ),
        LevelConfig(
          level: 53,
          topicEn: 'Combined Factorization',
          topicMs: 'Pemfaktoran Gabungan',
          descriptionEn: 'Combined techniques',
          descriptionMs: 'Teknik gabungan',
          type: LevelType.factorization,
        ),
      ],
    ),

    // Phase 12: Quadratic Equations
    LearningPhase(
      phaseNumber: 12,
      nameEn: 'Quadratic Equations',
      nameMs: 'Persamaan Kuadratik',
      color: AppColors.phaseColors[11],
      levels: [
        LevelConfig(
          level: 54,
          topicEn: 'Intro to Quadratics',
          topicMs: 'Pengenalan Kuadratik',
          descriptionEn: 'ax² + bx + c = 0',
          descriptionMs: 'ax² + bx + c = 0',
          type: LevelType.quadratic,
        ),
      ],
    ),

    // Phase 13: Pythagorean Theorem
    LearningPhase(
      phaseNumber: 13,
      nameEn: 'Pythagorean Theorem',
      nameMs: 'Teorem Pythagoras',
      color: AppColors.phaseColors[12],
      levels: [
        LevelConfig(
          level: 57,
          topicEn: 'Intro to Pythagorean Theorem',
          topicMs: 'Pengenalan Teorem Pythagoras',
          descriptionEn: 'a² + b² = c² — label sides, find hypotenuse',
          descriptionMs: 'a² + b² = c² — labelkan sisi, cari hipotenus',
          type: LevelType.pythagorean,
        ),
        LevelConfig(
          level: 58,
          topicEn: 'Perfect Square Triangles',
          topicMs: 'Segi Tiga Kuasa Dua Sempurna',
          descriptionEn: 'Find hypotenuse using perfect square triples',
          descriptionMs: 'Cari hipotenus menggunakan triplet kuasa dua sempurna',
          type: LevelType.pythagorean,
        ),
        LevelConfig(
          level: 59,
          topicEn: 'Non-Perfect Square Problems',
          topicMs: 'Masalah Bukan Kuasa Dua Sempurna',
          descriptionEn: 'Calculate hypotenuse by computation',
          descriptionMs: 'Kira hipotenus melalui pengiraan',
          type: LevelType.pythagorean,
        ),
        LevelConfig(
          level: 60,
          topicEn: 'Word Problems',
          topicMs: 'Masalah Bertulis',
          descriptionEn: 'Real-world Pythagorean problems',
          descriptionMs: 'Masalah Pythagoras dunia sebenar',
          type: LevelType.pythagorean,
        ),
        LevelConfig(
          level: 61,
          topicEn: 'Algebraic Pythagoras',
          topicMs: 'Pythagoras Algebra',
          descriptionEn: 'Combined algebra and geometry',
          descriptionMs: 'Gabungan algebra dan geometri',
          type: LevelType.pythagorean,
        ),
        LevelConfig(
          level: 62,
          topicEn: 'Distance Formula',
          topicMs: 'Formula Jarak',
          descriptionEn: '√[(x₂-x₁)² + (y₂-y₁)²]',
          descriptionMs: '√[(x₂-x₁)² + (y₂-y₁)²]',
          type: LevelType.pythagorean,
        ),
      ],
    ),
  ];

  /// Get all levels as a flat list
  static List<LevelConfig> get allLevels {
    return phases.expand((phase) => phase.levels).toList();
  }

  /// Get level by level number
  static LevelConfig? getLevel(int levelNumber) {
    for (final phase in phases) {
      for (final level in phase.levels) {
        if (level.level == levelNumber) return level;
      }
    }
    return null;
  }

  /// Get phase by level number
  static LearningPhase? getPhaseForLevel(int levelNumber) {
    for (final phase in phases) {
      for (final level in phase.levels) {
        if (level.level == levelNumber) return phase;
      }
    }
    return null;
  }

  /// Get total number of levels
  static int get totalLevels => allLevels.length;
}
