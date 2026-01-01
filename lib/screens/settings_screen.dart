import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/screens/language_screen.dart';
import 'package:pashu_swasthya/screens/history_screen.dart';
import 'package:pashu_swasthya/screens/about_screen.dart';
import 'package:pashu_swasthya/screens/help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A9C89), // same as home
                Color(0xFFC1D8C3), // same as home
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: Text(
          localizationService.translate('settings'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white, // back button color
        ),
      ),

      body: SingleChildScrollView(
        padding: AppTheme.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(localizationService.translate('general')),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.history,
              title: localizationService.translate('history'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: localizationService.translate('language'),
              trailing: _getLanguageName(
                localizationService.locale.languageCode,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LanguageSelectionScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: localizationService.translate('notifications'),
              trailingWidget: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              onTap: () {},
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(localizationService.translate('data_offline')),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.sync,
              title: localizationService.translate('offline_data_update'),
              subtitle: 'Last sync: 2 hours ago', // TODO: Localize time
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.delete,
              title: localizationService.translate('clear_cache'),
              onTap: () => _showClearCacheDialog(localizationService),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(localizationService.translate('about')),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.info,
              title: '${localizationService.translate('about')} ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.help,
              title: localizationService.translate('help_support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी';
      case 'ml':
        return 'മലയാളം';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF6A9C89)),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle:
            subtitle != null
                ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
                : null,
        trailing:
            trailingWidget ??
            (trailing != null
                ? Text(
                  trailing,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                )
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                )),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
      ),
    );
  }

  void _showClearCacheDialog(LocalizationService localizationService) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizationService.translate('clear_cache')),
            content: Text(
              localizationService.translate('are_you_sure_clear_cache'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizationService.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement cache clearing logic
                  Navigator.pop(context);
                },
                child: Text(localizationService.translate('clear')),
              ),
            ],
          ),
    );
  }
}
