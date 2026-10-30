import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/notification_service.dart';
import '../theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "Preferences",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text("Toggle between light and dark theme"),
                  value: appState.isDarkMode,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (val) {
                    appState.toggleTheme();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text("Enable Notifications", style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text("Allow Focus Lab to send task reminders"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final granted = await NotificationService.requestPermissions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              granted
                                  ? "Notifications enabled successfully!"
                                  : "Notification permission was denied or not granted.",
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Grant Permission"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "About",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: const [
                ListTile(
                  title: Text("App Name", style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text("Focus Lab", style: TextStyle(color: Colors.grey)),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text("Version", style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text("1.0.0+1", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
