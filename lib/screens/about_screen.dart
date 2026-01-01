import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
              colors: [Color(0xFF6A9C89), Color(0xFFC1D8C3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          localizationService.translate('about'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizationService.translate('app_name'),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            Text(
              localizationService.translate('app_version'),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAboutProject(context, localizationService),
                  const SizedBox(height: 32),
                  Text(
                    localizationService.translate('developers_title'),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3E5C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDevelopersGrid(context, localizationService),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Made with ❤️ for Farmers',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutProject(BuildContext context, LocalizationService ls) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF6A9C89),
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                ls.translate('about_project_title'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E3E5C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ls.translate('about_project_description'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopersGrid(BuildContext context, LocalizationService ls) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: [
        _buildDeveloperCard(
          context,
          ls.translate('dev1_name'),
          ls.translate('dev1_role'),
          ls.translate('dev1_contact'),
          'assets/images/dev1.png',
        ),
        _buildDeveloperCard(
          context,
          ls.translate('dev2_name'),
          ls.translate('dev2_role'),
          ls.translate('dev2_contact'),
          'assets/images/dev2.png',
        ),
        _buildDeveloperCard(
          context,
          ls.translate('dev3_name'),
          ls.translate('dev3_role'),
          ls.translate('dev3_contact'),
          'assets/images/dev3.png',
        ),
        _buildDeveloperCard(
          context,
          ls.translate('dev4_name'),
          ls.translate('dev4_role'),
          ls.translate('dev4_contact'),
          'assets/images/dev4.png',
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context,
    String name,
    String role,
    String contact,
    String imagePath,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFC1D8C3),
            backgroundImage: AssetImage(imagePath),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback if image not found
            },
            child:
                name.isNotEmpty
                    ? Text(
                      name[0],
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    )
                    : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3E5C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            role,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6A9C89),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(
              Icons.email_outlined,
              size: 20,
              color: Colors.blue,
            ),
            onPressed: () => _launchEmail(contact),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=PashuSwasthya Inquiry',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Could not launch email: $e');
    }
  }
}
