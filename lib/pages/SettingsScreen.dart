import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/auth/auth_service.dart';
import 'package:news_app/widgets/button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();
  bool _isDarkMode = true;
  String _selectedLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _isDarkMode = data?['isDarkMode'] ?? true;
          _selectedLanguage = data?['language'] ?? 'vi';
        });
        _updateLocale();
      }
    }
  }

  void _savePreferences(String language, bool isDarkMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'language': language,
        'isDarkMode': isDarkMode,
      });
      setState(() {
        _selectedLanguage = language;
        _isDarkMode = isDarkMode;
      });
      _updateLocale();
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDarkMode);
    }
  }

  void _updateLocale() {
    final locale = _selectedLanguage == 'vi' ? const Locale('vi', 'VN') : const Locale('en', 'US');
    Intl.defaultLocale = locale.toString();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "Vui lòng đăng nhập để tiếp tục.",
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.themeData.scaffoldBackgroundColor, // Đồng bộ với ThemeProvider
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedLanguage == 'vi' ? "Cài đặt" : "Settings",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        _selectedLanguage == 'vi' ? "Lỗi tải thông tin người dùng." : "Error loading user info.",
                        style: const TextStyle(color: Colors.redAccent),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                    }
                    final userData = snapshot.data!.data() as Map<String, dynamic>?;
                    final email = user.email ?? 'Không có email';
                    final role = userData?['role'] ?? 'user';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.themeData.cardColor, // Đồng bộ với ThemeProvider
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${_selectedLanguage == 'vi' ? "Vai trò" : "Role"}: ${role.toUpperCase()}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(
                    Icons.brightness_6,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    _selectedLanguage == 'vi' ? "Chế độ tối" : "Dark Mode",
                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                  ),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      _savePreferences(_selectedLanguage, value);
                    },
                    activeColor: Colors.redAccent,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    _selectedLanguage == 'vi' ? "Ngôn ngữ" : "Language",
                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.redAccent,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _savePreferences(newValue, _isDarkMode);
                      }
                    },
                    items: <String>['vi', 'en']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == 'vi' ? 'Tiếng Việt' : 'English'),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  label: _selectedLanguage == 'vi' ? "Đăng xuất" : "Logout",
                  onPressed: () async {
                    await _auth.signOut(context);
                  },
                  color: Colors.redAccent,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}