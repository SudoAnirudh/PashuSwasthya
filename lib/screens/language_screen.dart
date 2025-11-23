import 'package:flutter/material.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/screens/navigation_screen.dart';

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
      MaterialPageRoute(builder: (_) => const NavigationScreen()),
    );
  }

  void _onLanguageSelected(String code) {
    Provider.of<LocalizationService>(
      context,
      listen: false,
    ).setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final currentCode = localizationService.locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: AppTheme.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              /// ✅ Main Title (Now this is your only header)
              Text(
                localizationService.translate('choose_language'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A9C89),
                ),
              ),

              const SizedBox(height: 65),

              /// ✅ Language List
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = language['code'] == currentCode;

                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? AppTheme.primaryGreen
                                  : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      tileColor:
                          isSelected
                              ? AppTheme.primaryGreen.withOpacity(0.06)
                              : Colors.white,
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            isSelected
                                ? AppTheme.primaryGreen.withOpacity(0.15)
                                : Colors.grey.shade100,
                        child: Text(
                          language['code']!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? AppTheme.primaryGreen
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      title: Text(
                        language['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? AppTheme.primaryGreen
                                  : AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        language['native']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryGreen,
                              )
                              : const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                      onTap: () {
                        _onLanguageSelected(language['code']!);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// ✅ Continue Button
              ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF6A9C89),
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
}
