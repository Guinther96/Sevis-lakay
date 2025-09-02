import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Personal Info
          settingsTile(
            icon: Icons.person,
            title: 'Personal Information',
            onTap: () {
              // Naviguer vers la page d'infos personnelles
              Navigator.pushNamed(context, '/personal_info');
            },
          ),

          // Notifications
          settingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              // Naviguer vers la page de notifications
              Navigator.pushNamed(context, '/notifications');
            },
          ),

          // Security
          settingsTile(
            icon: Icons.lock,
            title: 'Security',
            onTap: () {
              Navigator.pushNamed(context, '/security');
            },
          ),

          // Help
          settingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),

          const Divider(height: 32),

          // Logout
          settingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            iconColor: Colors.red,
            onTap: () {
              // Déconnecter l'utilisateur
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Appelle la fonction de déconnexion
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget settingsTile({
    required IconData icon,
    required String title,
    Color iconColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
