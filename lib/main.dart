import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:news_app/api/firebase_api.dart';
import 'package:news_app/pages/login_screen.dart';
import 'package:news_app/pages/notification_page.dart';
import 'package:news_app/pages/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

final navigatorKey = GlobalKey<NavigatorState>();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseApi().initNotifications();

  // Load ngôn ngữ mặc định từ Firestore
  String initialLanguage = 'vi'; // Mặc định Tiếng Việt
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      initialLanguage = data?['language'] ?? 'vi';
    }
  }
  final locale = initialLanguage == 'vi' ? const Locale('vi', 'VN') : const Locale('en', 'US');
  Intl.defaultLocale = locale.toString();

  // Khởi tạo dữ liệu định dạng ngày tháng
  await initializeDateFormatting(locale.toString(), null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
          theme: themeProvider.themeData,
          locale: Locale(Intl.defaultLocale!), // Đặt locale cho ứng dụng
          home: const LoginScreen(),
          routes: {
            '/notification_screen': (context) => const NotificationPage(),
          },
        );
      },
    );
  }
}