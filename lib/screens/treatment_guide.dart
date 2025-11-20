import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pashu_swasthya/models/treatment_guide.dart';
import 'package:pashu_swasthya/services/treatment_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pashu_swasthya/services/localization_service.dart';

class TreatmentGuidesScreen extends StatefulWidget {
  final String? diseaseName;
  final TreatmentGuide? treatmentGuide;
  
  const TreatmentGuidesScreen({
    super.key,
    this.diseaseName,
    this.treatmentGuide,
  });

  @override
  State<TreatmentGuidesScreen> createState() => _TreatmentGuidesScreenState();
}

class _TreatmentGuidesScreenState extends State<TreatmentGuidesScreen> {
  final TreatmentService _treatmentService = TreatmentService();
  TreatmentGuide? _selectedGuide;

  @override
  void initState() {
    super.initState();
    if (widget.treatmentGuide != null) {
      _selectedGuide = widget.treatmentGuide;
    } else if (widget.diseaseName != null) {
      _selectedGuide = _treatmentService.getTreatmentGuide(widget.diseaseName!);
    }
  }

  String _getDiseaseName(TreatmentGuide guide, LocalizationService localizationService) {
    switch (guide.code) {
      case 'FMD':
        return localizationService.translate('disease_fmd');
      case 'MAST':
        return localizationService.translate('disease_mastitis');
      case 'LSD':
        return localizationService.translate('disease_lsd');
      case 'BRUC':
        return localizationService.translate('disease_brucellosis');
      case 'ANTH':
        return localizationService.translate('disease_anthrax');
      default:
        return guide.diseaseName;
    }
  }

  Future<void> _callEmergencyContact(String contact) async {
    // Extract phone number from contact string
    final phoneRegex = RegExp(r'[\d+\-\(\)\s]+');
    final match = phoneRegex.firstMatch(contact);
    if (match != null) {
      final phoneNumber = match.group(0)?.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (phoneNumber != null) {
        final uri = Uri.parse('tel:$phoneNumber');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${Provider.of<LocalizationService>(context, listen: false).translate('cannot_make_call')}: $phoneNumber')),
          );
        }
      }
    }
  }

  Widget _buildTreatmentSection(String title, List<String> items, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(TreatmentGuide guide) {
    final localizationService = Provider.of<LocalizationService>(context);
    if (!guide.isSevere || guide.emergencyContacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                localizationService.translate('emergency_severe_disease'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            localizationService.translate('contact_vet_immediately'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...guide.emergencyContacts.map((contact) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _callEmergencyContact(contact),
              icon: const Icon(Icons.phone),
              label: Expanded(child: Text(contact)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getLocalizedList(String code, String section, List<String> defaultList) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final key = 'disease_${code.toLowerCase()}_$section';
    final localizedString = localizationService.translate(key);
    
    // If the key returns itself (meaning translation missing) or is empty, return default
    if (localizedString == key || localizedString.isEmpty) {
      return defaultList;
    }
    
    return localizedString.split('|').map((e) => e.trim()).toList();
  }

  Widget _buildDiseaseGuide(TreatmentGuide guide) {
    final localizationService = Provider.of<LocalizationService>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease Header
          Card(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDiseaseName(guide, localizationService),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  if (guide.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      // Try to localize description too if available
                      localizationService.translate('disease_${guide.code.toLowerCase()}_description') != 'disease_${guide.code.toLowerCase()}_description'
                          ? localizationService.translate('disease_${guide.code.toLowerCase()}_description')
                          : guide.description,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Emergency Section
          _buildEmergencySection(guide),
          
          // Symptoms
          _buildTreatmentSection(
            localizationService.translate('symptoms'),
            _getLocalizedList(guide.code, 'symptoms', guide.symptoms),
            Icons.sick,
          ),
          
          // Treatment Steps
          _buildTreatmentSection(
            localizationService.translate('treatment_steps'),
            _getLocalizedList(guide.code, 'treatment_steps', guide.treatmentSteps),
            Icons.medical_services,
          ),
          
          // Precautions
          _buildTreatmentSection(
            localizationService.translate('precautions'),
            _getLocalizedList(guide.code, 'precautions', guide.precautions),
            Icons.shield,
          ),
          
          // First Aid
          _buildTreatmentSection(
            localizationService.translate('first_aid'),
            _getLocalizedList(guide.code, 'first_aid', guide.firstAid),
            Icons.emergency,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGuide != null ? _getDiseaseName(_selectedGuide!, localizationService) : localizationService.translate('treatment_guides')),
        centerTitle: true,
      ),
      body: _selectedGuide != null
          ? _buildDiseaseGuide(_selectedGuide!)
          : _buildDiseaseList(),
    );
  }

  Widget _buildDiseaseList() {
    final localizationService = Provider.of<LocalizationService>(context);
    final allGuides = _treatmentService.getAllTreatmentGuides();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allGuides.length,
      itemBuilder: (context, index) {
        final guide = allGuides[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              guide.isSevere ? Icons.warning : Icons.medical_services,
              color: guide.isSevere ? Colors.red : AppTheme.primaryGreen,
            ),
            title: Text(
              _getDiseaseName(guide, localizationService),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(guide.description.isEmpty ? guide.code : guide.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _selectedGuide = guide;
              });
            },
          ),
        );
      },
    );
  }
}
