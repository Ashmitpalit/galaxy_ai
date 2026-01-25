import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../data/models/photo_model.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/pin_detail_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/saved_items_screen.dart';
import '../../presentation/screens/account_settings_screen.dart';
import '../../presentation/screens/board_detail_screen.dart';
import '../../presentation/widgets/scaffold_with_navbar.dart';
import '../../presentation/screens/messages_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_flow_screen.dart';


final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Check if user is signed in
    final user = ClerkAuth.userOf(context);
    final isSignedIn = user != null;
    
    // List of auth routes that don't require authentication
    final authRoutes = ['/welcome', '/login', '/signup'];
    final isAuthRoute = authRoutes.contains(state.matchedLocation);
    
    // If not signed in and trying to access protected route, redirect to welcome
    if (!isSignedIn && !isAuthRoute) {
      return '/welcome';
    }
    
    // If signed in and trying to access auth routes, redirect to home
    if (isSignedIn && isAuthRoute) {
      return '/';
    }
    
    return null; // No redirect needed
  },
  routes: [
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
        // Tab 3: Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        // Tab 4: Saved Items (Pins/Boards/Collages)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedItemsScreen(),
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
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/board/:id',
      builder: (context, state) {
        final boardId = state.pathParameters['id']!;
        return BoardDetailScreen(boardId: boardId);
      },
    ),
    // Auth routes
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupFlowScreen(),
    ),
  ],
);
