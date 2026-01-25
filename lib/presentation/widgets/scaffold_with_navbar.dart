import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../core/theme/app_theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: navigationShell.currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(navigationShell.currentIndex == 0 ? Icons.home : Icons.home_outlined, size: 30),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(navigationShell.currentIndex == 1 ? Icons.search : Icons.search_outlined, size: 30),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 30),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(navigationShell.currentIndex == 3 ? Icons.message : Icons.message_outlined, size: 28),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(context, navigationShell.currentIndex == 4),
              label: 'Profile',
            ),
          ],
          onTap: (index) => _onTap(context, index),
        ),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context, bool isSelected) {
    // Try to get Clerk user - this will be null if ClerkAuth is not in the widget tree
    // (which happens on non-profile screens)
    try {
      final user = ClerkAuth.userOf(context);
      
      if (user != null) {
        // User is logged in
        if (user.imageUrl != null) {
          // Show profile picture
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.black, width: 2.5) : null,
              image: DecorationImage(
                image: NetworkImage(user.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          // Show first letter of name
          final email = user.emailAddresses?.firstOrNull?.emailAddress;
          final username = user.username ?? email?.split('@').first ?? 'U';
          final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';
          
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              border: isSelected ? Border.all(color: Colors.black, width: 2.5) : null,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // ClerkAuth not in tree or error - show generic icon
    }
    
    // Not logged in - show generic icon
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: isSelected ? Border.all(color: Colors.black, width: 2.5) : null,
      ),
      child: const Icon(Icons.person, size: 18, color: Colors.grey),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      _showCreateOptions(context);
    } else {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer
                const Text(
                  'Start creating now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCreateOption(context, 'Pin', Icons.push_pin_outlined),
                _buildCreateOption(context, 'Collage', Icons.cut_outlined),
                _buildCreateOption(context, 'Board', Icons.dashboard_customize_outlined),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(BuildContext context, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(icon, size: 32, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
