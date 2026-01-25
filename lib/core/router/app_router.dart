import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/photo_model.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/pin_detail_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/saved_items_screen.dart';
import '../../presentation/screens/account_settings_screen.dart';
import '../../presentation/widgets/scaffold_with_navbar.dart';
import '../../presentation/screens/messages_screen.dart';

final router = GoRouter(
  initialLocation: '/',
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
  ],
);
