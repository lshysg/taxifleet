// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1565C0);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
      case 'DONE':
        return Colors.green;
      case 'BUSY':
      case 'CANCELLED':
        return Colors.grey;
      case 'UNAVAILABLE':
        return Colors.grey.shade600;
      case 'NEW':
        return Colors.blue;
      case 'ASSIGNED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Color statusBadgeColor(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
        return Colors.green;
      case 'BUSY':
        return Colors.red;
      case 'UNAVAILABLE':
        return Colors.grey;
      case 'NEW':
        return Colors.blue;
      case 'ASSIGNED':
        return Colors.orange;
      case 'DONE':
        return Colors.green;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
        return 'Свободен';
      case 'BUSY':
        return 'Занят';
      case 'UNAVAILABLE':
        return 'Недоступен';
      case 'NEW':
        return 'Новый';
      case 'ASSIGNED':
        return 'Назначен';
      case 'DONE':
        return 'Выполнен';
      case 'CANCELLED':
        return 'Отменён';
      default:
        return status;
    }
  }
}
