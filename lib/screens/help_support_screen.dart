import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          localizationService.translate('help_support'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(context, localizationService),
            const SizedBox(height: 30),
            _buildFAQSection(context, localizationService),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('contact_title'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 15),
        _buildContactCard(
          icon: Icons.email_outlined,
          title: 'Email',
          value: 'support@pashuswasthya.ai',
          onTap: () => _launchURL('mailto:support@pashuswasthya.ai'),
        ),
        _buildContactCard(
          icon: Icons.phone_outlined,
          title: 'Emergency Vet Helpline',
          value: '+91 1800-456-7890',
          onTap: () => _launchURL('tel:+9118004567890'),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6A9C89).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6A9C89)),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQSection(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    final faqs = [
      {
        'q': 'How does the breed detection work?',
        'a':
            'The app uses offline-ready TensorFlow Lite models to analyze cattle images and identify common breeds with high confidence.',
      },
      {
        'q': 'Can I use this app without internet?',
        'a':
            'Yes! PashuSwasthya is designed to work fully offline. All models and treatment guides are stored on your device.',
      },
      {
        'q': 'What should I do in an emergency?',
        'a':
            'If the app detects a severe disease, please contact the emergency helpline immediately or seek help from a local veterinarian.',
      },
      {
        'q': 'How do I update the offline data?',
        'a':
            'Go to Settings > Data & Offline > Offline Data Update while connected to the internet to download the latest updates.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 15),
        ...faqs.map((faq) => _buildFAQTile(faq['q']!, faq['a']!)).toList(),
      ],
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text(
          answer,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
