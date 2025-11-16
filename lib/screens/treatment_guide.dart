import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pashu_swasthya/models/treatment_guide.dart';
import 'package:pashu_swasthya/services/treatment_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

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
            SnackBar(content: Text('Cannot make call: $phoneNumber')),
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
                'EMERGENCY - Severe Disease Detected',
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
            'Contact a veterinarian immediately:',
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

  Widget _buildDiseaseGuide(TreatmentGuide guide) {
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
                    guide.diseaseName,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  if (guide.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      guide.description,
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
            'Symptoms',
            guide.symptoms,
            Icons.sick,
          ),
          
          // Treatment Steps
          _buildTreatmentSection(
            'Treatment Steps',
            guide.treatmentSteps,
            Icons.medical_services,
          ),
          
          // Precautions
          _buildTreatmentSection(
            'Precautions',
            guide.precautions,
            Icons.shield,
          ),
          
          // First Aid
          _buildTreatmentSection(
            'First Aid',
            guide.firstAid,
            Icons.emergency,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGuide != null ? _selectedGuide!.diseaseName : 'Treatment Guides'),
        centerTitle: true,
      ),
      body: _selectedGuide != null
          ? _buildDiseaseGuide(_selectedGuide!)
          : _buildDiseaseList(),
    );
  }

  Widget _buildDiseaseList() {
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
              guide.diseaseName,
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
