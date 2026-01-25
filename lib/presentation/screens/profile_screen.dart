import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: SafeArea(
          child: ProfileHeader(),
        ),
      ),
    );
  }
}
