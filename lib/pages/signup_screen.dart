import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_app/auth/auth_service.dart';
import 'package:news_app/pages/home_screen.dart';
import 'package:news_app/pages/login_screen.dart';
import 'package:news_app/widgets/button.dart';
import 'package:news_app/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
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
                    // Signup Form Card
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
                            "Create Account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            hint: "Enter Name",
                            label: "Name",
                            controller: _name,
                            prefixIcon: const Icon(Icons.person, color: Colors.redAccent),
                            isPassword: false,
                          ),
                          const SizedBox(height: 15),
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
                            label: "Signup",
                            onPressed: () => _signup(context),
                            color: Colors.redAccent,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Navigation Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => goToLogin(context),
                          child: const Text(
                            "Login",
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

  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  goToHome(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  _signup(BuildContext context) async {
    final user = await _auth.createUserWithEmailAndPassword(
        _email.text, _password.text, 'user', context);
    if (user != null) {
      log("User Created Successfully");
      goToHome(context);
    }
  }
}