import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app/pages/home_screen.dart';
import 'package:news_app/pages/login_screen.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  /// Đăng nhập bằng Google
  Future<UserCredential?> loginWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        log("Google Sign-In bị hủy");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        log("Đăng nhập thành công: ${userCredential.user!.email}");
        await _saveUserRole(userCredential.user!.uid, 'user');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return userCredential;
    } catch (e) {
      log("Lỗi đăng nhập Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng nhập Google: $e")),
      );
    }
    return null;
  }

  /// Tạo tài khoản với Email & Password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String role, BuildContext context) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        await _saveUserRole(cred.user!.uid, role);
        log("Tài khoản được tạo với vai trò: $role, UID: ${cred.user!.uid}");
      }
      return cred.user;
    } catch (e) {
      log("Lỗi tạo tài khoản: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tạo tài khoản: $e")),
      );
    }
    return null;
  }

  /// Đăng nhập với Email & Password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        log("User Logged In: ${cred.user!.email}, UID: ${cred.user!.uid}");
        // Kiểm tra và lưu vai trò nếu chưa có
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .get();
        if (!userDoc.exists) {
          await _saveUserRole(cred.user!.uid, 'user');
          log("Tạo mới vai trò 'user' cho UID: ${cred.user!.uid}");
        } else {
          log("Vai trò hiện tại: ${userDoc['role']}");
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return cred.user;
    } catch (e) {
      log("Lỗi đăng nhập: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng nhập: $e")),
      );
    }
    return null;
  }

  /// Đăng xuất
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      log("Lỗi đăng xuất: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng xuất: $e")),
      );
    }
  }

  /// Lưu vai trò người dùng vào Firestore
  Future<void> _saveUserRole(String uid, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      log("Lưu vai trò thành công: $role cho UID: $uid");
    } catch (e) {
      log("Lỗi khi lưu vai trò: $e");
      throw Exception("Không thể lưu vai trò: $e");
    }
  }

  /// Kiểm tra vai trò người dùng
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        log("Vai trò của UID $uid: ${doc['role']}");
        return doc['role'];
      } else {
        log("Không tìm thấy vai trò cho UID: $uid");
        return null;
      }
    } catch (e) {
      log("Lỗi lấy vai trò người dùng: $e");
      return null;
    }
  }
}