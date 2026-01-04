import 'package:pashu_swasthya/screens/vet_help_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/screens/combined_detection_screen.dart';
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
  /// 🌟 Premium Welcome Header with 3D Asset
  Widget _buildWelcomeHeader(
    LocalizationService localizationService,
    BuildContext context,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final appBarHeight = AppBar().preferredSize.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            width: double.infinity,
            height: isTablet ? 320 : 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF6A9C89)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Decorative Circle 1
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: topPadding + appBarHeight + 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizationService.translate('welcome'),
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 30 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: isTablet ? 350 : 220,
                      child: Text(
                        localizationService.translate('home_subtitle'),
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✨ Premium Glassmorphic Card Widget with 3D Asset
  Widget _buildPremiumCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8F5E9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Row(
                children: [
                  // Icon instead of 3D Asset
                  Container(
                    height: isTablet ? 90 : 75,
                    width: isTablet ? 90 : 75,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: color, size: isTablet ? 45 : 38),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 19 : 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B261F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 13 : 12,
                            color: const Color(0xFF5A665E),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF6A9C89),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Home Body
  Widget _buildHomeContent(
    LocalizationService localizationService,
    BuildContext context,
  ) {
    final padding = AppTheme.getResponsivePadding(context);

    return Stack(
      children: [
        // Background Decorative Circles
        Positioned(
          bottom: 150,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF6A9C89).withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 350,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFC1D8C3).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),

        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildWelcomeHeader(localizationService, context),
              Padding(
                padding: padding.copyWith(top: 10),
                child: Column(
                  children: [
                    _buildPremiumCard(
                      context: context,
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF2E7BB2),
                      title: localizationService.translate(
                        'breed_disease_detection',
                      ),
                      subtitle: localizationService.translate(
                        'breed_disease_subtitle',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CombinedDetectionScreen(),
                          ),
                        );
                      },
                    ),

                    _buildPremiumCard(
                      context: context,
                      icon: Icons.auto_stories_rounded,
                      color: const Color(0xFF2E7D32),
                      title: localizationService.translate('treatment_guide'),
                      subtitle: localizationService.translate(
                        'treatment_guide_subtitle',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TreatmentGuidesScreen(),
                          ),
                        );
                      },
                    ),

                    _buildPremiumCard(
                      context: context,
                      icon: Icons.local_hospital_rounded,
                      color: const Color(0xFFE53935),
                      title: localizationService.translate('vet_help'),
                      subtitle: localizationService.translate(
                        'vet_help_subtitle',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VetHelpScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FBF9),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              localizationService.translate('app_name'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 20,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildHomeContent(localizationService, context),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40.0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 4),
      size.height - 80,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
