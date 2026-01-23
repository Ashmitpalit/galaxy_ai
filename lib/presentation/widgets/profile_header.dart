import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ClerkAuth.userOf(context);
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final email = user.emailAddresses?.firstOrNull?.emailAddress;
    final username = user.username ?? email?.split('@').first ?? 'User';
    final handle = user.username != null ? '@${user.username}' : (email ?? '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        // Avatar
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: user.imageUrl != null 
              ? NetworkImage(user.imageUrl!) 
              : null,
          child: user.imageUrl == null
              ? Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          user.name.isNotEmpty ? user.name : username,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Handle
        Text(
          handle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        // Stats
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('0 followers'),
            Text(' · '),
            Text('0 following'),
          ],
        ),
        const SizedBox(height: 24),
        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                await ClerkAuth.of(context).signOut();
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Share'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.9,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (context, scrollController) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                              ),
                              const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Done', style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              children: [
                                const SizedBox(height: 20),
                                Center(
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey[200],
                                        child: const Text('U', style: TextStyle(fontSize: 40)),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _buildTextField('First name', 'User'),
                                _buildTextField('Last name', ''),
                                _buildTextField('Username', 'username'),
                                _buildTextField('About', '', maxLines: 3),
                                _buildTextField('Website', ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  Widget _buildTextField(String label, String initialValue, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
