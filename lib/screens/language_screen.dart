import 'package:flutter/material.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _currentPage = 0;
  // We don't need local selectedLanguage state anymore as we'll use the service

  final List<Map<String, String>> languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'code': 'ml'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'code': 'kn'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'code': 'ta'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize page controller to current locale if possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      final currentCode = localizationService.locale.languageCode;
      final index = languages.indexWhere((lang) => lang['code'] == currentCode);
      if (index != -1) {
        setState(() {
          _currentPage = index;
        });
        // If using a PageController, we would jumpToPage here
      }
    });
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _onLanguageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    final code = languages[index]['code']!;
    Provider.of<LocalizationService>(context, listen: false).setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    // Ensure PageController is synced with current page
    final PageController pageController = PageController(initialPage: _currentPage);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(localizationService.translate('select_language')),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppTheme.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizationService.translate('choose_language'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: languages.length,
                  onPageChanged: _onLanguageChanged,
                  itemBuilder: (context, index) {
                    return _buildLanguageCard(
                      language: languages[index],
                      isSelected: index == _currentPage,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  languages.length,
                  (index) => _buildPageIndicator(index == _currentPage),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _continue,
                child: Text(localizationService.translate('continue_btn')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required Map<String, String> language,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
           // Find index of this language
           final index = languages.indexOf(language);
           _onLanguageChanged(index);
        },
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                language['name']!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language['native']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreen : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
