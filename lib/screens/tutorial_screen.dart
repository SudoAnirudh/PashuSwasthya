import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/screens/navigation_screen.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/services/storage_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final StorageService _storageService = StorageService();

  final List<TutorialItem> _items = [
    TutorialItem(
      titleKey: 'tutorial_welcome_title',
      descriptionKey: 'tutorial_welcome_desc',
      lottieAsset: 'assets/animations/welcome.json',
      icon: Icons.pets,
    ),
    TutorialItem(
      titleKey: 'tutorial_scan_title',
      descriptionKey: 'tutorial_scan_desc',
      lottieAsset: 'assets/animations/scan.json',
      icon: Icons.qr_code_scanner,
    ),
    TutorialItem(
      titleKey: 'tutorial_offline_title',
      descriptionKey: 'tutorial_offline_desc',
      lottieAsset: 'assets/animations/offline.json',
      icon: Icons.cloud_off,
    ),
    TutorialItem(
      titleKey: 'tutorial_vet_title',
      descriptionKey: 'tutorial_vet_desc',
      lottieAsset: 'assets/animations/vet.json',
      icon: Icons.local_hospital,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() async {
    await _storageService.saveUserPreference('has_seen_tutorial', 'true');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onFinish,
                child: Text(
                  localizationService.translate('skip'),
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 100,
                              color: AppTheme.primaryGreen,
                            ),
                            // Note: If you have lottie assets, use them like this:
                            // child: Lottie.asset(
                            //   item.lottieAsset,
                            //   repeat: true,
                            //   errorBuilder: (context, error, stackTrace) => Icon(...),
                            // ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          localizationService.translate(item.titleKey),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizationService.translate(item.descriptionKey),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _items.length - 1) {
                          _onFinish();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _items.length - 1
                            ? localizationService.translate('get_started')
                            : localizationService.translate('next'),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialItem {
  final String titleKey;
  final String descriptionKey;
  final String lottieAsset;
  final IconData icon;

  TutorialItem({
    required this.titleKey,
    required this.descriptionKey,
    required this.lottieAsset,
    required this.icon,
  });
}
