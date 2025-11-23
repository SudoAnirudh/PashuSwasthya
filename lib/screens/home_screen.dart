import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/screens/combined_detection_screen.dart';
import 'package:pashu_swasthya/screens/treatment_guide.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:pashu_swasthya/services/database_helper.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDetails = await DatabaseHelper().getUserDetails();
    if (mounted) {
      setState(() {
        _userName = userDetails['user_name'];
      });
    }
  }

  /// 🌊 Wavy Welcome Header (No Image)
  Widget _buildWelcomeHeader(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final appBarHeight = AppBar().preferredSize.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        width: double.infinity,
        height: isTablet ? 250 : 220,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: topPadding + appBarHeight + 20, // Fixes spacing
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A9C89), Color(0xFFC1D8C3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userName != null ? "👋 Welcome, $_userName!" : "👋 Welcome!",
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Let’s take care of your cattle’s health today.",
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 15 : 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Full Width Card
  Widget _buildFullWidthCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return SizedBox(
      width: double.infinity,
      height: isTablet ? 180 : 150,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 28 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isTablet ? 42 : 32,
                    color: Color(0xFF6A9C89),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 20 : 16,
                  color: AppTheme.primaryGreen,
                ),
              ],
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

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWelcomeHeader(context),

          Padding(
            padding: padding,
            child: Column(
              children: [
                const SizedBox(height: 20),

                _buildFullWidthCard(
                  context: context,
                  icon: Icons.camera_alt,
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

                const SizedBox(height: 20),

                _buildFullWidthCard(
                  context: context,
                  icon: Icons.book,
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

                const SizedBox(height: 20),

                _buildFullWidthCard(
                  context: context,
                  icon: Icons.call,
                  title: localizationService.translate('vet_help'),
                  subtitle: localizationService.translate('vet_help_subtitle'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizationService.translate(
                            'vet_connect_coming_soon',
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundWhite,

          /// ✅ This removes the gap under AppBar
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            backgroundColor: Colors.transparent, // Overlay look
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  localizationService.translate('app_name'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 22 : 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  localizationService.translate('app_subtitle'),
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          body: _buildHomeContent(localizationService, context),
        );
      },
    );
  }
}

/// 🌊 Wave Clipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 30);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 35,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 60,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
