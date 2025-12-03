import 'package:flutter/material.dart';
import 'package:love_notes/pages/login_page.dart';
import 'package:love_notes/pages/signup_page.dart';

class LoginOrSignup extends StatefulWidget {
  const LoginOrSignup({super.key});

  @override
  State<LoginOrSignup> createState() => _LoginOrSignupState();
}

class _LoginOrSignupState extends State<LoginOrSignup> {

  bool isLogin = true;

  void togglePage() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginPage(onPressed: togglePage);
    } else {
      return SignupPage(onPressed: togglePage);
    }
  }
}