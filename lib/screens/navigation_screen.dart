import 'package:flutter/material.dart';
import 'package:pashu_swasthya/screens/home_screen.dart';
import 'package:pashu_swasthya/screens/settings_screen.dart';
import 'package:pashu_swasthya/screens/voice_input.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({super.key, this.initialIndex = 1});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final screens = [
          VoiceInputScreen(localeId: localizationService.locale.toString()),
          const HomeScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: screens[_currentIndex],

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,

            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.mic),
                label: "Voice",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          ),
        );
      },
    );
  }
}
