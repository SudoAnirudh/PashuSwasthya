import 'dart:ui';
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
  final TextEditingController _searchController = TextEditingController();
  TreatmentGuide? _selectedGuide;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    if (widget.treatmentGuide != null) {
      _selectedGuide = widget.treatmentGuide;
    } else if (widget.diseaseName != null) {
      _selectedGuide = _treatmentService.getTreatmentGuide(widget.diseaseName!);
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getDiseaseName(
    TreatmentGuide guide,
    LocalizationService localizationService,
  ) {
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
            SnackBar(
              content: Text(
                '${Provider.of<LocalizationService>(context, listen: false).translate('cannot_make_call')}: $phoneNumber',
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildGlassCard({required Widget child, Color? color, double? blur}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
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
      child: child,
    );
  }

  Widget _buildTreatmentSection(
    String title,
    List<String> items,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _buildGlassCard(
        blur: 5,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.textPrimary.withOpacity(
                                        0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
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
      child: _buildGlassCard(
        color: Colors.red.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizationService.translate('emergency_severe_disease'),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                localizationService.translate('contact_vet_immediately'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 16),
              ...guide.emergencyContacts.map(
                (contact) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergencyContact(contact),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: Text(
                      contact,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getLocalizedList(
    String code,
    String section,
    List<String> defaultList,
  ) {
    final localizationService = Provider.of<LocalizationService>(
      context,
      listen: false,
    );
    final key = 'disease_${code.toLowerCase()}_$section';
    final localizedString = localizationService.translate(key);

    if (localizedString == key || localizedString.isEmpty) {
      return defaultList;
    }

    return localizedString.split('|').map((e) => e.trim()).toList();
  }

  Widget _buildDiseaseGuide(TreatmentGuide guide) {
    final localizationService = Provider.of<LocalizationService>(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            color: AppTheme.primaryGreen,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDiseaseName(guide, localizationService),
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (guide.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      localizationService.translate(
                                'disease_${guide.code.toLowerCase()}_description',
                              ) !=
                              'disease_${guide.code.toLowerCase()}_description'
                          ? localizationService.translate(
                            'disease_${guide.code.toLowerCase()}_description',
                          )
                          : guide.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildEmergencySection(guide),

          _buildTreatmentSection(
            localizationService.translate('symptoms'),
            _getLocalizedList(guide.code, 'symptoms', guide.symptoms),
            Icons.sick_rounded,
          ),

          _buildTreatmentSection(
            localizationService.translate('treatment_steps'),
            _getLocalizedList(
              guide.code,
              'treatment_steps',
              guide.treatmentSteps,
            ),
            Icons.medical_information_rounded,
          ),

          _buildTreatmentSection(
            localizationService.translate('precautions'),
            _getLocalizedList(guide.code, 'precautions', guide.precautions),
            Icons.verified_user_rounded,
          ),

          _buildTreatmentSection(
            localizationService.translate('first_aid'),
            _getLocalizedList(guide.code, 'first_aid', guide.firstAid),
            Icons.emergency_rounded,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          color:
              (_selectedGuide != null
                  ? Colors.transparent
                  : AppTheme.primaryGreen),
        ),
        title: Text(
          _selectedGuide != null
              ? _getDiseaseName(_selectedGuide!, localizationService)
              : localizationService.translate('treatment_guides'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child:
                _selectedGuide != null
                    ? _buildDiseaseGuide(_selectedGuide!)
                    : _buildDiseaseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseList() {
    final localizationService = Provider.of<LocalizationService>(context);
    List<TreatmentGuide> allGuides = _treatmentService.getAllTreatmentGuides();

    if (_searchQuery.isNotEmpty) {
      allGuides =
          allGuides.where((guide) {
            final name =
                _getDiseaseName(guide, localizationService).toLowerCase();
            final symptoms =
                _getLocalizedList(
                  guide.code,
                  'symptoms',
                  guide.symptoms,
                ).join(' ').toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) ||
                symptoms.contains(_searchQuery.toLowerCase());
          }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Container(
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search diseases or symptoms...",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primaryGreen,
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        Expanded(
          child:
              allGuides.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No matching guides found",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: allGuides.length,
                    itemBuilder: (context, index) {
                      final guide = allGuides[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGlassCard(
                          blur: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (guide.isSevere
                                        ? Colors.red
                                        : AppTheme.primaryGreen)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                guide.isSevere
                                    ? Icons.warning_rounded
                                    : Icons.medical_services_rounded,
                                color:
                                    guide.isSevere
                                        ? Colors.red
                                        : AppTheme.primaryGreen,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              _getDiseaseName(guide, localizationService),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              localizationService.translate(
                                        'disease_${guide.code.toLowerCase()}_description',
                                      ) !=
                                      'disease_${guide.code.toLowerCase()}_description'
                                  ? localizationService.translate(
                                    'disease_${guide.code.toLowerCase()}_description',
                                  )
                                  : (guide.description.isEmpty
                                      ? guide.code
                                      : guide.description),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedGuide = guide;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
