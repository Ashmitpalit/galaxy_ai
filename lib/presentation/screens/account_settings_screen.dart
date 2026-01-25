import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Your account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Profile card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildProfileAvatar(context),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserName(context),
                              const SizedBox(height: 4),
                              _buildUserHandle(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'View profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Share profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Settings section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem('Account management'),
            _buildSettingItem('Profile visibility'),
            _buildSettingItem('Refine your recommendations'),
            _buildSettingItem('Link to Pinterest'),
            _buildSettingItem('Social permissions and activity'),
            _buildSettingItem('Notifications'),
            _buildSettingItem('Privacy and data'),
            _buildSettingItem('Reports and violations center'),
            const SizedBox(height: 32),
            _buildSettingItem('Login', isLast: true, onTap: () async {
              try {
                final user = ClerkAuth.userOf(context);
                if (user != null) {
                  await ClerkAuth.of(context).signOut();
                  if (context.mounted) {
                    context.go('/saved');
                  }
                }
              } catch (e) {
                // Handle error
              }
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    try {
      final user = ClerkAuth.userOf(context);
      if (user != null) {
        if (user.imageUrl != null) {
          return CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(user.imageUrl!),
          );
        } else {
          final email = user.emailAddresses?.firstOrNull?.emailAddress;
          final username = user.username ?? email?.split('@').first ?? 'U';
          final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';
          return CircleAvatar(
            radius: 32,
            backgroundColor: Colors.red,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Clerk not available
    }
    
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.grey, size: 32),
    );
  }

  Widget _buildUserName(BuildContext context) {
    try {
      final user = ClerkAuth.userOf(context);
      if (user != null) {
        final email = user.emailAddresses?.firstOrNull?.emailAddress;
        final name = user.name.isNotEmpty 
            ? user.name 
            : (user.username ?? email?.split('@').first ?? 'User');
        return Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    } catch (e) {
      // Clerk not available
    }
    
    return const Text(
      'User',
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserHandle(BuildContext context) {
    try {
      final user = ClerkAuth.userOf(context);
      if (user != null) {
        final email = user.emailAddresses?.firstOrNull?.emailAddress;
        final handle = user.username != null 
            ? '@${user.username}' 
            : (email ?? '');
        return Text(
          handle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        );
      }
    } catch (e) {
      // Clerk not available
    }
    
    return Text(
      '@user',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
      ),
    );
  }

  Widget _buildSettingItem(String title, {bool isLast = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
