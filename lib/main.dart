import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// TODO: Replace with your actual Clerk Publishable Key
const String clerkPublishableKey = 'pk_test_PLACEHOLDER_KEY';

void main() {
  runApp(
    ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: clerkPublishableKey,
      ),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pinterest Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
