// lib/theme_manager.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UITheme {
  classic, // Original main.dart UI
  modern,  // Enhanced theme.dart UI
}

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  UITheme _currentTheme = UITheme.classic;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UITheme get currentTheme => _currentTheme;

  Future<void> initializeTheme() async {
    try {
      // First try to get from Firestore (admin setting)
      final doc = await _firestore.collection('app_settings').doc('ui_theme').get();
      
      if (doc.exists && doc.data() != null) {
        final themeString = doc.data()!['theme'] as String?;
        if (themeString != null) {
          _currentTheme = UITheme.values.firstWhere(
            (theme) => theme.toString() == themeString,
            orElse: () => UITheme.classic,
          );
        }
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        final themeIndex = prefs.getInt('ui_theme') ?? 0;
        _currentTheme = UITheme.values[themeIndex];
      }
      
      notifyListeners();
    } catch (e) {
      print('Error initializing theme: $e');
      _currentTheme = UITheme.classic;
    }
  }

  Future<void> changeTheme(UITheme newTheme) async {
    if (_currentTheme == newTheme) return;

    _currentTheme = newTheme;
    notifyListeners();

    try {
      // Save to Firestore (for admin control)
      await _firestore.collection('app_settings').doc('ui_theme').set({
        'theme': newTheme.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also save locally as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ui_theme', newTheme.index);
    } catch (e) {
      print('Error saving theme: $e');
      // If Firestore fails, at least save locally
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('ui_theme', newTheme.index);
      } catch (localError) {
        print('Error saving theme locally: $localError');
      }
    }
  }

  String get themeDisplayName {
    switch (_currentTheme) {
      case UITheme.classic:
        return 'Classic Theme';
      case UITheme.modern:
        return 'Modern Glass Theme';
    }
  }

  IconData get themeIcon {
    switch (_currentTheme) {
      case UITheme.classic:
        return Icons.web;
      case UITheme.modern:
        return Icons.auto_awesome;
    }
  }

  Color get themeColor {
    switch (_currentTheme) {
      case UITheme.classic:
        return Colors.blue;
      case UITheme.modern:
        return Colors.purple;
    }
  }
}