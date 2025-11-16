import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pashu_swasthya/screens/splash_screen.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalizationService(),
      child: const PashuSwasthya(),
    ),
  );
}

class PashuSwasthya extends StatelessWidget {
  const PashuSwasthya({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PashuSwasthya - Cattle Health Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(isDark: false),
      home: const SplashScreen(),
    );
  }
}
