import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/theme_view_model.dart';
import '../../viewmodels/feed_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final feedVM = context.watch<FeedViewModel>();
    final user = authVM.user;
    final profile = authVM.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: Icon(themeVM.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeVM.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFFF8C00),
                  child: Text(
                    (profile?.displayName.isNotEmpty == true
                            ? profile!.displayName[0]
                            : user?.email?.isNotEmpty == true
                                ? user!.email![0]
                                : 'U')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? 'Wire Reader',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'subscriber@thewire.news',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8C00).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFF8C00)),
                        ),
                        child: const Text(
                          '★ PREMIUM SUBSCRIBER',
                          style: TextStyle(
                            color: Color(0xFFFF8C00),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Options list
          const Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Dark Theme'),
            trailing: Switch(
              value: themeVM.isDarkMode,
              activeColor: const Color(0xFFFF8C00),
              onChanged: (_) => themeVM.toggleTheme(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.wifi_off_outlined),
            title: const Text('Offline Mode Status'),
            subtitle: Text(feedVM.isOfflineMode ? 'Active (Reading Cached Feed)' : 'Online'),
            trailing: Icon(
              feedVM.isOfflineMode ? Icons.check_circle : Icons.cloud_done,
              color: feedVM.isOfflineMode ? Colors.amber : Colors.green,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.tune, color: Color(0xFFFF8C00)),
            title: const Text('Interest Walkthrough & Calibration'),
            subtitle: const Text('Recalibrate topics, entities, tone & time budget'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/onboarding'),
          ),
          const SizedBox(height: 24),

          const Text('ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Security & Privacy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/security-privacy'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => authVM.signOut(),
          ),
        ],
      ),
    );
  }
}
