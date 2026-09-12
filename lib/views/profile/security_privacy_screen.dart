import 'package:flutter/material.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const accentColor = Color(0xFFFF8C00);
    final surfaceColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E0D8);

    final privacyItems = [
      _PrivacyItem(
        icon: Icons.shield_outlined,
        title: 'Data Protection',
        description:
            'Your personal information is securely stored and protected from unauthorized access.',
      ),
      _PrivacyItem(
        icon: Icons.lock_person_outlined,
        title: 'Secure Authentication',
        description:
            'User accounts are protected with secure login and authentication methods.',
      ),
      _PrivacyItem(
        icon: Icons.visibility_off_outlined,
        title: 'Privacy of User Data',
        description:
            'Personal information and reading activity are kept private and are not shared without consent.',
      ),
      _PrivacyItem(
        icon: Icons.location_off_outlined,
        title: 'Location Privacy',
        description:
            'Location data is collected only when required for location-based news and can be disabled by the user.',
      ),
      _PrivacyItem(
        icon: Icons.delete_forever_outlined,
        title: 'Data Deletion',
        description:
            'Users can request deletion of their account and associated personal data.',
        isActionable: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Trust Banner Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26262B) : const Color(0xFFF9F6F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2DCD2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Commitment to Privacy',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Byline is engineered with strong reader privacy principles. Your reading habits, credentials, and personal telemetry remain strictly under your control.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'PRIVACY & SECURITY PILLARS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Pillars List
          ...privacyItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${item.title} – ${item.description}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.45,
                      ),
                    ),
                    if (item.isActionable) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDataDeletionDialog(context),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                          label: const Text(
                            'Request Account & Data Deletion',
                            style: TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent, width: 0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'Byline Independent Journalism • Confidentiality Assured',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDataDeletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Request Data Deletion'),
          ],
        ),
        content: const Text(
          'Users can request deletion of their account and associated personal data.\n\n'
          'Once submitted, your account profile, bookmarks, cached interests, and telemetry data will be queued for permanent removal within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Your data deletion request has been registered.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyItem {
  final IconData icon;
  final String title;
  final String description;
  final bool isActionable;

  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isActionable = false,
  });
}
