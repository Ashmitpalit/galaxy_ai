import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/photo_model.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/pin_detail_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/widgets/scaffold_with_navbar.dart';

import 'package:clerk_flutter/clerk_flutter.dart';
import '../../presentation/screens/auth_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Check if user is authenticated
    final authState = ClerkAuth.of(context);
    final isSignedIn = authState.isSignedIn; // Accessing the signed-in state
    
    // Define public and private routes
    final isGoingToProfile = state.uri.path == '/profile';
    final isGoingToAuth = state.uri.path == '/auth';

    // If not signed in and trying to go to profile, redirect to auth
    if (!isSignedIn && isGoingToProfile) {
      return '/auth';
    }

    // If signed in and trying to go to auth, redirect to profile (or home)
    if (isSignedIn && isGoingToAuth) {
      return '/profile';
    }

    // No redirect
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Search
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        // Tab 2: Create (Placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Create Screen Placeholder')),
              ),
            ),
          ],
        ),
        // Tab 3: Messages (Placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Messages Screen Placeholder')),
              ),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Full screen routes (outside shell)
    GoRoute(
      path: '/pin/:id',
      builder: (context, state) {
        final photo = state.extra as PhotoModel;
        return PinDetailScreen(photo: photo);
      },
    ),
  ],
);
