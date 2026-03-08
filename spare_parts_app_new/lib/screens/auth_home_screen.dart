import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthHomeScreen extends StatelessWidget {
  const AuthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spares Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginScreen(showAppBar: false, minimal: true),
            RegisterScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
