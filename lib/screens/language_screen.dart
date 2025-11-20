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
  final List<Map<String, String>> languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'code': 'ml'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'code': 'kn'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'code': 'ta'},
  ];

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _onLanguageSelected(String code) {
    Provider.of<LocalizationService>(context, listen: false).setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final currentCode = localizationService.locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(localizationService.translate('select_language')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppTheme.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                localizationService.translate('choose_language'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = language['code'] == currentCode;
                    return _buildLanguageCard(
                      language: language,
                      isSelected: isSelected,
                      onTap: () => _onLanguageSelected(language['code']!),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizationService.translate('continue_btn'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required Map<String, String> language,
    required bool isSelected,
    required VoidCallback onTap,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  language['code']!.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                language['name']!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                language['native']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
