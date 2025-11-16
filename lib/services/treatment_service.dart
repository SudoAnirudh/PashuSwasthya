import 'package:pashu_swasthya/models/treatment_guide.dart';

class TreatmentService {
  // Comprehensive offline treatment database
  final List<TreatmentGuide> _treatmentGuides = [
    TreatmentGuide(
      diseaseName: 'Foot and Mouth Disease',
      code: 'FMD',
      description: 'A highly contagious viral disease affecting cloven-hoofed animals.',
      symptoms: [
        'Fever (up to 106°F)',
        'Blisters in the mouth and on the feet',
        'Excessive drooling',
        'Lameness and reluctance to move',
        'Loss of appetite',
        'Reduced milk production',
      ],
      treatmentSteps: [
        'Isolate the infected animal immediately',
        'Keep the animal in a clean, dry, and comfortable environment',
        'Provide soft, palatable feed and plenty of fresh water',
        'Clean blisters with mild antiseptic solution (diluted iodine)',
        'Apply antibiotic ointment to prevent secondary bacterial infections',
        'Administer pain relief medication as prescribed by veterinarian',
        'Monitor temperature daily',
        'Ensure proper nutrition with vitamin supplements',
      ],
      precautions: [
        'Quarantine new animals for at least 21 days',
        'Disinfect footwear, equipment, and vehicles before entering farm',
        'Avoid contact with other farms during outbreak',
        'Vaccinate healthy animals as per veterinary schedule',
        'Dispose of contaminated materials properly',
        'Wash hands and change clothes after handling infected animals',
        'Report to local veterinary authorities immediately',
      ],
      firstAid: [
        'Separate the animal from the herd immediately',
        'Clean affected areas with clean water and mild soap',
        'Apply antiseptic solution to blisters',
        'Provide soft bedding to reduce discomfort',
        'Ensure access to clean water and soft feed',
        'Contact veterinarian immediately for proper treatment',
      ],
      isSevere: true,
      emergencyContacts: [
        'Local Veterinary Hospital: 1800-XXX-XXXX',
        'Emergency Vet Helpline: 1800-YYY-YYYY',
        'District Animal Husbandry: 1800-ZZZ-ZZZZ',
      ],
    ),
    TreatmentGuide(
      diseaseName: 'Mastitis',
      code: 'MAST',
      description: 'Inflammation of the udder tissue, usually caused by bacterial infection.',
      symptoms: [
        'Swelling, heat, and redness of the udder',
        'Hardness and pain in the udder',
        'Abnormal milk appearance (watery, flakes, clots)',
        'Reduced milk production',
        'Fever in severe cases',
        'Loss of appetite',
      ],
      treatmentSteps: [
        'Milk out the affected quarter frequently (every 2-3 hours)',
        'Apply warm compresses to the udder to reduce swelling',
        'Administer antibiotics as prescribed by veterinarian',
        'Use intramammary antibiotic tubes as directed',
        'Ensure proper milking hygiene',
        'Provide anti-inflammatory medication if needed',
        'Continue treatment for full course (usually 5-7 days)',
        'Monitor milk quality before resuming consumption',
      ],
      precautions: [
        'Maintain strict milking hygiene',
        'Clean udder before and after milking',
        'Use separate cloths for each animal',
        'Disinfect milking equipment regularly',
        'Dry off animals properly after milking',
        'Isolate infected animals during treatment',
        'Test milk regularly for early detection',
      ],
      firstAid: [
        'Stop milking the affected quarter',
        'Apply cold compress to reduce swelling',
        'Keep the animal in a clean, dry area',
        'Provide plenty of fresh water',
        'Contact veterinarian for antibiotic treatment',
        'Do not consume milk from affected quarter',
      ],
      isSevere: false,
    ),
    TreatmentGuide(
      diseaseName: 'Lumpy Skin Disease',
      code: 'LSD',
      description: 'A viral disease transmitted by blood-feeding insects, causing skin nodules.',
      symptoms: [
        'Fever (103-106°F)',
        'Nodules or lumps on the skin (2-5 cm diameter)',
        'Swelling of limbs and brisket',
        'Watery eyes and nasal discharge',
        'Reduced milk production',
        'Loss of appetite',
        'Difficulty in movement',
      ],
      treatmentSteps: [
        'Isolate infected animals immediately',
        'Provide supportive care and good nutrition',
        'Clean skin nodules with antiseptic solution',
        'Apply antibiotic ointment to prevent secondary infections',
        'Administer antibiotics for secondary bacterial infections',
        'Provide pain relief and anti-inflammatory medication',
        'Ensure adequate hydration',
        'Monitor for complications',
      ],
      precautions: [
        'Control insect vectors (flies, mosquitoes, ticks)',
        'Use insect repellents and insecticides',
        'Vaccinate healthy animals',
        'Quarantine new animals',
        'Maintain good hygiene and sanitation',
        'Dispose of contaminated materials properly',
        'Report to veterinary authorities',
      ],
      firstAid: [
        'Isolate the animal from the herd',
        'Clean skin nodules with mild antiseptic',
        'Keep the animal in a clean, shaded area',
        'Provide fresh water and soft feed',
        'Contact veterinarian for proper treatment',
        'Monitor temperature and general condition',
      ],
      isSevere: true,
      emergencyContacts: [
        'Local Veterinary Hospital: 1800-XXX-XXXX',
        'Emergency Vet Helpline: 1800-YYY-YYYY',
        'District Animal Husbandry: 1800-ZZZ-ZZZZ',
      ],
    ),
    TreatmentGuide(
      diseaseName: 'Brucellosis',
      code: 'BRUC',
      description: 'A bacterial disease that can cause abortion in cattle and is zoonotic.',
      symptoms: [
        'Late-term abortion',
        'Retained placenta',
        'Reduced milk production',
        'Infertility',
        'Swollen testicles in bulls',
        'Weak calves',
      ],
      treatmentSteps: [
        'Consult veterinarian immediately',
        'Isolate infected animals',
        'Test all animals in the herd',
        'Cull or separate infected animals as per veterinary advice',
        'Vaccinate healthy animals',
        'Maintain strict biosecurity measures',
        'Disinfect contaminated areas',
      ],
      precautions: [
        'Test all new animals before introduction',
        'Vaccinate heifers before first breeding',
        'Practice good hygiene when handling aborted fetuses',
        'Wear protective clothing',
        'Dispose of aborted materials properly',
        'Avoid consuming raw milk from infected animals',
        'Report to veterinary authorities',
      ],
      firstAid: [
        'Isolate the animal immediately',
        'Wear protective clothing when handling',
        'Dispose of aborted materials safely',
        'Contact veterinarian for testing and treatment',
        'Do not consume raw milk',
      ],
      isSevere: true,
      emergencyContacts: [
        'Local Veterinary Hospital: 1800-XXX-XXXX',
        'Emergency Vet Helpline: 1800-YYY-YYYY',
        'District Animal Husbandry: 1800-ZZZ-ZZZZ',
      ],
    ),
    TreatmentGuide(
      diseaseName: 'Anthrax',
      code: 'ANTH',
      description: 'A serious bacterial disease that can be fatal and is zoonotic.',
      symptoms: [
        'Sudden death (often first sign)',
        'High fever',
        'Difficulty breathing',
        'Swelling of neck and throat',
        'Bloody discharge from body openings',
        'Convulsions before death',
      ],
      treatmentSteps: [
        'DO NOT OPEN THE CARCASS - contact authorities immediately',
        'Isolate any sick animals',
        'Vaccinate all healthy animals',
        'Disinfect contaminated areas thoroughly',
        'Follow veterinary and health department guidelines',
        'Report to authorities immediately',
      ],
      precautions: [
        'Vaccinate animals annually',
        'Avoid opening carcasses of sudden death',
        'Dispose of carcasses properly (burning or deep burial)',
        'Disinfect contaminated areas',
        'Wear protective clothing',
        'Report suspected cases immediately',
        'Quarantine affected area',
      ],
      firstAid: [
        'DO NOT TOUCH OR OPEN THE CARCASS',
        'Isolate the area immediately',
        'Contact veterinary and health authorities',
        'Keep people and animals away',
        'Wait for proper disposal instructions',
      ],
      isSevere: true,
      emergencyContacts: [
        'Emergency Veterinary: 1800-XXX-XXXX',
        'Health Department: 1800-YYY-YYYY',
        'District Animal Husbandry: 1800-ZZZ-ZZZZ',
      ],
    ),
  ];

  TreatmentGuide? getTreatmentGuide(String diseaseName) {
    try {
      return _treatmentGuides.firstWhere(
        (guide) => guide.diseaseName.toLowerCase() == diseaseName.toLowerCase(),
      );
    } catch (e) {
      // Try matching by code
      try {
        return _treatmentGuides.firstWhere(
          (guide) => guide.code.toLowerCase() == diseaseName.toLowerCase(),
        );
      } catch (e) {
        return null;
      }
    }
  }

  List<TreatmentGuide> getAllTreatmentGuides() {
    return List.unmodifiable(_treatmentGuides);
  }

  List<TreatmentGuide> searchTreatmentGuides(String query) {
    final lowerQuery = query.toLowerCase();
    return _treatmentGuides.where((guide) {
      return guide.diseaseName.toLowerCase().contains(lowerQuery) ||
          guide.code.toLowerCase().contains(lowerQuery) ||
          guide.symptoms.any((symptom) => symptom.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}

