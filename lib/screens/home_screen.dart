import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/screens/combined_detection_screen.dart';
import 'package:pashu_swasthya/screens/settings_screen.dart';
import 'package:pashu_swasthya/screens/voice_input.dart';
import 'package:pashu_swasthya/screens/treatment_guide.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 28 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isTablet ? 40 : 32,
                  color: AppTheme.primaryGreen,
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 14 : 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Home Screen Content
  Widget _buildHomeContent(
    LocalizationService localizationService,
    BuildContext context,
  ) {
    final crossAxisCount = AppTheme.getGridCrossAxisCount(context);
    final padding = AppTheme.getResponsivePadding(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 1200 : double.infinity,
        ),
        child: GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isTablet ? 24 : 20,
            mainAxisSpacing: isTablet ? 24 : 20,
            childAspectRatio: isTablet ? 0.9 : 0.85,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildGridCard(
                  context: context,
                  icon: Icons.camera_alt,
                  title: 'Breed & Disease Detection',
                  subtitle:
                      'Identify breed first, then detect diseases automatically.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CombinedDetectionScreen(),
                      ),
                    );
                  },
                );
              case 1:
                return _buildGridCard(
                  context: context,
                  icon: Icons.book,
                  title: localizationService.translate('treatment_guide'),
                  subtitle: 'Access offline guides for common treatments.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TreatmentGuidesScreen(),
                      ),
                    );
                  },
                );
              case 2:
                return _buildGridCard(
                  context: context,
                  icon: Icons.call,
                  title: localizationService.translate('vet_help'),
                  subtitle: 'Connect with a certified vet for expert advice.',
                  onTap: () {
                    // TODO: Add Vet Connect feature
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vet Connect feature coming soon!'),
                      ),
                    );
                  },
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }

  /// 🔹 Full Screen Scaffold
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundWhite,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            title: Column(
              children: [
                Text(
                  'PashuSwasthya',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 22 : 18,
                  ),
                ),
                Text(
                  'Cattle Health Assistant',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => VoiceInputScreen(
                            localeId: localizationService.locale.toString(),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _buildHomeContent(localizationService, context),
        );
      },
    );
  }
}
