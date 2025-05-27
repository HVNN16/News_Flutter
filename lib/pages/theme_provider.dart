import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode
      ? ThemeData.dark().copyWith(
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: Colors.grey.shade900,
    cardColor: Colors.grey.shade800,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.redAccent, // Đảm bảo màu chữ và biểu tượng hiển thị rõ
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.redAccent),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  )
      : ThemeData.light().copyWith(
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.grey.shade100,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.redAccent, // Đảm bảo màu chữ và biểu tượng hiển thị rõ
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.redAccent),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  void _loadThemePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        _isDarkMode = data?['isDarkMode'] ?? true;
        notifyListeners();
      }
    }
  }

  void toggleTheme(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isDarkMode': value,
      });
      _isDarkMode = value;
      notifyListeners();
    }
  }
}