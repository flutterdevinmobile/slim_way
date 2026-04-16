import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Palette from User Request (#00A651)
  static const green = Color(0xFF00A651);
  static const darkGreen = Color(0xFF007A3E);
  static const black = Color(0xFF121212);
  static const white = Color(0xFFFFFFFF);
  static const gray = Color(0xFFF6F6F6);
  static const darkGray = Color(0xFF1C1C1E);
  static const accentColor = green;
  
  static const primaryColor = green;
  
  // Gradients
  static const greenGradient = LinearGradient(
    colors: [green, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const lightGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9F9F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: green,
      scaffoldBackgroundColor: gray,
      colorScheme: ColorScheme.light(
        primary: green,
        secondary: green,
        surface: white,
        onSurface: black,
        outline: Colors.black.withOpacity(0.05),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: black,
        displayColor: black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: black),
        titleTextStyle: TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: green,
      scaffoldBackgroundColor: black,
      colorScheme: ColorScheme.dark(
        primary: green,
        secondary: green,
        surface: darkGray,
        onSurface: white,
        outline: Colors.white.withOpacity(0.05),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: white,
        displayColor: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
