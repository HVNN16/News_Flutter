import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_app/auth/auth_service.dart';
import 'package:news_app/pages/signup_screen.dart';
import 'package:news_app/widgets/button.dart';
import 'package:news_app/widgets/textfield.dart';

import 'AdminRegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or App Name
                    const Icon(
                      Icons.newspaper,
                      size: 80,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "NewsApp",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Login Form Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            hint: "Enter Email",
                            label: "Email",
                            controller: _email,
                            prefixIcon: const Icon(Icons.email, color: Colors.redAccent),
                            isPassword: false,
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            hint: "Enter Password",
                            label: "Password",
                            controller: _password,
                            prefixIcon: const Icon(Icons.lock, color: Colors.redAccent),
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: "Login",
                            onPressed: () async {
                              await _auth.loginUserWithEmailAndPassword(
                                  _email.text, _password.text, context);
                            },
                            color: Colors.redAccent,
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          CustomButton(
                            label: "Sign in with Google",
                            onPressed: () async {
                              await _auth.loginWithGoogle(context);
                            },
                            color: Colors.grey.shade700,
                            textColor: Colors.white,
                            borderColor: Colors.redAccent,
                            icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Navigation Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Are you an admin? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminRegisterScreen()),
                          ),
                          child: const Text(
                            "Register as Admin",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}