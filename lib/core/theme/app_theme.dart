import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.appBarColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.appBarColor,
        surface:
            AppColors.cardWhiteBg, // Kartlar ve diyaloglar için yüzey rengi
        onPrimary: AppColors.textLight, // Ana renk üzerindeki metin/ikon rengi
        onSecondary:
            AppColors.textPrimary, // İkincil renk üzerindeki metin/ikon rengi
        onSurface:
            AppColors.textPrimary, // Yüzeyler üzerindeki metin/ikon rengi
        onError:
            AppColors.textLight, // Hata renkleri üzerindeki metin/ikon rengi
        error: AppColors.gradeRed, // Hata mesajları için genel renk
      ),
      textTheme: GoogleFonts.poppinsTextTheme(_textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appBarColor,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 15),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.appBarColor,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.cardWhiteBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.appBarColor;
          }
          return AppColors.inputBorder; // Seçili değilken kenarlık rengi
        }),
        checkColor: WidgetStateProperty.all(AppColors.textLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.topHeaderBg,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      // Diğer tema ayarları buraya eklenebilir
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.appBarColor,
        secondary: Colors.deepPurpleAccent,
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white60),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appBarColor, width: 1.5),
        ),
      ),
    );
  }

  // Kivy'deki font boyutlarına ve stillerine karşılık gelen temel metin teması
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ), // Örn: Ana Başlıklar
    displayMedium: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ), // Örn: Kart Başlıkları
    displaySmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ), // Örn: Etiketler (Bold)

    headlineMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ), // Örn: Normal metin (biraz büyük)
    headlineSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ), // Örn: Standart metin
    titleLarge: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ), // Kivy'deki 17sp bold

    bodyLarge: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ), // Örn: Input metni
    bodyMedium: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: AppColors.textHint,
    ), // Örn: Alt başlıklar, ipuçları
    bodySmall: GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: AppColors.textHint,
    ), // Örn: En küçük metinler

    labelLarge: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColors.textLight,
      letterSpacing: 0.5,
    ), // Buton metni için
    labelMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textHint,
    ),
  );

  // Kivy'deki FONT_REGULAR ve FONT_BOLD'a karşılık gelen stiller
  static TextStyle get regularTextStyle =>
      GoogleFonts.poppins(color: AppColors.textPrimary);
  static TextStyle get boldTextStyle => GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const Map<String, double> _gradeValues = {
    'AA': 4.0,
    'BA': 3.5,
    'BB': 3.0,
    'CB': 2.5,
    'CC': 2.0,
    'DC': 1.5,
    'DD': 1.0,
    'FD': 0.5,
    'FF': 0.0,
    // Diğer notlar (GR, DZ vb.) için de değerler eklenebilir veya varsayılan bir davranış belirlenebilir.
    // Şimdilik sadece harf notlarını ele alıyoruz.
  };

  // Harf notu renkleri için yardımcı fonksiyon (GNO ile karşılaştırmalı)
  static Color getGradeColor(String? letterGrade, {String? gpaString}) {
    if (letterGrade == null) return AppColors.gradeDefaultText;
    final normalizedGrade = letterGrade.toUpperCase().trim();

    // GNO'yu double'a çevir
    double? gpa;
    if (gpaString != null) {
      gpa = double.tryParse(gpaString.replaceAll(',', '.'));
    }

    final double? gradeValue = _gradeValues[normalizedGrade];

    if (gpa != null && gradeValue != null) {
      if (gradeValue >= gpa) {
        return AppColors.gradeGreen; // Not GNO'dan büyük veya eşitse yeşil
      } else {
        return AppColors.gradeRed; // Not GNO'dan küçükse kırmızı
      }
    }

    // GNO yoksa veya harf notunun sayısal karşılığı yoksa eski mantığa dön
    const greenGrades = ["AA", "BA", "BB", "CB"];
    const redGrades = ["CC", "DC", "DD", "FD", "FF"];
    if (greenGrades.contains(normalizedGrade)) {
      return AppColors.gradeGreen;
    } else if (redGrades.contains(normalizedGrade)) {
      return AppColors.gradeRed;
    }

    return AppColors.gradeDefaultText;
  }
}
