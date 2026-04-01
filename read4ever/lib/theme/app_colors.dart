import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Light mode ---
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC); // card/sheet backgrounds
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A); // cool-tinted near-black
  static const textSecondary = Color(0xFF64748B); // metadata, captions
  static const accent = Color(0xFF0D9488); // teal-600
  static const accentSubtle =
      Color(0xFFCCFBF1); // teal-100 — highlight tint, badges
  static const onAccent = Color(0xFFFFFFFF);

  // --- Dark mode ---
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const borderDark = Color(0xFF334155);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);
  // accent stays the same — reads well on both
}
