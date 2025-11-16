import 'package:pashu_swasthya/models/disease.dart';

/// Symptom-based Disease Identification Service
/// Used for voice input and text-based symptom matching
class SymptomDiseaseService {
  final List<Disease> _diseases = [
    Disease(
      name: 'Foot and Mouth Disease',
      symptoms: [
        'Fever',
        'Blisters in the mouth and on the feet',
        'Drooling',
        'Lameness',
        'Loss of appetite',
        'Reduced milk production',
      ],
      keywords: [
        'foot', 'mouth', 'blisters', 'drooling', 'lame', 'lameness',
        'ulcer', 'hoof', 'saliva', 'fever', 'cannot walk', 'tongue wound',
        'highly contagious', 'mouth disease',
      ],
    ),
    Disease(
      name: 'Mastitis',
      symptoms: [
        'Inflammation of the udder',
        'Swelling, heat, hardness, redness, or pain in the udder',
        'Abnormalities in milk, such as a watery appearance, flakes, or clots',
        'Reduced milk production',
      ],
      keywords: [
        'mastitis', 'udder', 'swelling', 'milk', 'clots', 'blood in milk',
        'yellow milk', 'udder pain', 'hot udder', 'udder infection',
        'swollen udder', 'clotted milk',
      ],
    ),
    Disease(
      name: 'Lumpy Skin Disease',
      symptoms: [
        'Fever',
        'Nodules or lumps on the skin',
        'Swelling of the limbs and brisket',
        'Watery eyes',
        'Reduced milk production',
      ],
      keywords: [
        'lumpy', 'skin', 'nodules', 'lumps', 'swelling', 'lumpy skin',
        'body lumps', 'skin infection', 'fever with lumps', 'eye discharge',
        'nose discharge', 'ticks disease',
      ],
    ),
    Disease(
      name: 'Brucellosis',
      symptoms: [
        'Late-term abortion',
        'Retained placenta',
        'Reduced milk production',
        'Infertility',
        'Weak calves',
      ],
      keywords: [
        'abortion', 'aborted', 'retained placenta', 'infertility',
        'weak calf', 'stillborn', 'breeding problem',
      ],
    ),
    Disease(
      name: 'Anthrax',
      symptoms: [
        'Sudden death',
        'High fever',
        'Difficulty breathing',
        'Swelling of neck',
        'Bloody discharge',
      ],
      keywords: [
        'sudden death', 'died suddenly', 'bloody discharge', 'swollen neck',
        'difficulty breathing', 'convulsions',
      ],
    ),
  ];

  /// Identify disease from symptom text with confidence scoring
  DiseaseIdentification? identifyDisease(String transcribedText) {
    if (transcribedText.isEmpty) return null;
    
    final lowerText = transcribedText.toLowerCase();
    final matches = <DiseaseMatch>[];
    
    for (final disease in _diseases) {
      int matchCount = 0;
      final matchedKeywords = <String>[];
      
      for (final keyword in disease.keywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          matchCount++;
          matchedKeywords.add(keyword);
        }
      }
      
      if (matchCount > 0) {
        final confidence = (matchCount / disease.keywords.length * 100).clamp(0.0, 100.0);
        matches.add(DiseaseMatch(
          disease: disease,
          confidence: confidence,
          matchedKeywords: matchedKeywords,
        ));
      }
    }
    
    if (matches.isEmpty) return null;
    
    // Sort by confidence and return top match
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    final topMatch = matches.first;
    
    return DiseaseIdentification(
      disease: topMatch.disease,
      confidence: topMatch.confidence,
      matchedKeywords: topMatch.matchedKeywords,
      allMatches: matches.map((m) => m.disease).toList(),
    );
  }
}

class DiseaseMatch {
  final Disease disease;
  final double confidence;
  final List<String> matchedKeywords;
  
  DiseaseMatch({
    required this.disease,
    required this.confidence,
    required this.matchedKeywords,
  });
}

class DiseaseIdentification {
  final Disease disease;
  final double confidence;
  final List<String> matchedKeywords;
  final List<Disease> allMatches;
  
  DiseaseIdentification({
    required this.disease,
    required this.confidence,
    required this.matchedKeywords,
    required this.allMatches,
  });
}

