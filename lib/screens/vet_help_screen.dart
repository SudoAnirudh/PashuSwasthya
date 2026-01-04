import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/services/location_service.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class Vet {
  final String name;
  final String specialty;
  final String phone;
  final double lat;
  final double lon;
  final double rating;

  Vet({
    required this.name,
    required this.specialty,
    required this.phone,
    required this.lat,
    required this.lon,
    required this.rating,
  });
}

class VetHelpScreen extends StatefulWidget {
  const VetHelpScreen({super.key});

  @override
  State<VetHelpScreen> createState() => _VetHelpScreenState();
}

class _VetHelpScreenState extends State<VetHelpScreen> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoading = false;
  List<Map<String, dynamic>> _nearbyVets = [];

  final List<Vet> _allVets = [
    Vet(
      name: 'Bombay Veterinary College Hospital',
      specialty: 'Multispecialty Hospital',
      phone: '02224131180',
      lat: 19.0176,
      lon: 72.8561,
      rating: 4.5,
    ),
    Vet(
      name: 'Madras Veterinary College Hospital',
      specialty: 'Teaching Hospital',
      phone: '04425304000',
      lat: 13.0844,
      lon: 80.2699,
      rating: 4.7,
    ),
    Vet(
      name: 'Hebbal Veterinary Hospital',
      specialty: 'Government Hospital',
      phone: '08023414614',
      lat: 13.0359,
      lon: 77.5888,
      rating: 4.3,
    ),
    Vet(
      name: 'Sanjay Gandhi Animal Care Centre',
      specialty: 'Animal Welfare & Hospital',
      phone: '01125448062',
      lat: 28.6534,
      lon: 77.1245,
      rating: 4.6,
    ),
    Vet(
      name: 'Govt Veterinary Polyclinic, Pune',
      specialty: 'Cattle Specialist',
      phone: '02025531234',
      lat: 18.5204,
      lon: 73.8567,
      rating: 4.2,
    ),
    Vet(
      name: 'Dr. Rajesh Dental & Animal Clinic',
      specialty: 'Small & Large Animals',
      phone: '+919876543210',
      lat: 19.1200,
      lon: 72.9100,
      rating: 4.8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchVets();
  }

  Future<void> _fetchVets() async {
    setState(() => _isLoading = true);

    _currentPosition = await _locationService.getCurrentLocation();

    if (_currentPosition != null) {
      _nearbyVets =
          _allVets.map((vet) {
            double distanceInMeters = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              vet.lat,
              vet.lon,
            );
            return {
              'vet': vet,
              'distance': (distanceInMeters / 1000).toStringAsFixed(1),
              'distanceValue': distanceInMeters,
            };
          }).toList();

      // Sort by distance
      _nearbyVets.sort(
        (a, b) => (a['distanceValue'] as double).compareTo(
          b['distanceValue'] as double,
        ),
      );
    } else {
      // If location fails, just use mock distances for first 3
      _nearbyVets =
          _allVets.take(3).map((vet) {
            return {'vet': vet, 'distance': '?.?', 'distanceValue': 0.0};
          }).toList();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        centerTitle: true,
        title: Text(
          localizationService.translate('vet_help'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchVets,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchVets,
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚨 Emergency Section
              _buildEmergencyCard(localizationService),
              const SizedBox(height: 30),

              // 👨‍⚕️ Top Veterinarians Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizationService.translate('available_vets'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (_currentPosition != null)
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 5),
              if (_currentPosition == null && !_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    localizationService.translate('location_not_available'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_nearbyVets.isEmpty)
                Center(
                  child: Text(
                    'No veterinarians found nearby.',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              else
                ..._nearbyVets.map((data) {
                  final Vet vet = data['vet'];
                  final String distance = data['distance'];
                  return _buildVetListItem(
                    vet: vet,
                    distance: distance,
                    context: context,
                    localizationService: localizationService,
                  );
                }).toList(),

              const SizedBox(height: 30),

              // 🏛 Government Resources
              _buildGovernmentResourcesCard(localizationService),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(LocalizationService localizationService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 50,
          ),
          const SizedBox(height: 12),
          Text(
            localizationService.translate('emergency_severe_disease'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizationService.translate('contact_vet_immediately'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _makePhoneCall('1962'),
            icon: const Icon(
              Icons.phone_in_talk_rounded,
              color: Color(0xFFE53935),
            ),
            label: Text(
              localizationService.translate('call_toll_free'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE53935),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVetListItem({
    required Vet vet,
    required String distance,
    required BuildContext context,
    required LocalizationService localizationService,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F5E9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          child: Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
        ),
        title: Text(
          vet.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vet.specialty,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                Text(
                  ' $distance ${localizationService.translate('km_away')}',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(
                  ' ${vet.rating}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.phone_rounded, color: AppTheme.primaryGreen),
            onPressed: () => _makePhoneCall(vet.phone),
          ),
        ),
      ),
    );
  }

  Widget _buildGovernmentResourcesCard(
    LocalizationService localizationService,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBBDEFB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_rounded,
                color: Color(0xFF1976D2),
              ),
              const SizedBox(width: 12),
              Text(
                localizationService.translate('govt_resources'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizationService.translate('govt_resources_desc'),
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              const url = 'https://dahd.nic.in/';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1976D2),
              side: const BorderSide(color: Color(0xFF1976D2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              localizationService.translate('view_official_directory'),
            ),
          ),
        ],
      ),
    );
  }
}
