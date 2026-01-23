import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ClerkAuthentication(),
      ),
    );
  }
}
