import 'package:pashu_swasthya/models/disease.dart';

/// Symptom-based Disease Identification Service
/// Used for voice input and text-based symptom matching
/// Supports both English and Hindi keywords
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
        // English keywords
        'foot', 'mouth', 'blisters', 'drooling', 'lame', 'lameness',
        'ulcer', 'hoof', 'saliva', 'fever', 'cannot walk', 'tongue wound',
        'highly contagious', 'mouth disease', 'foot disease', 'blister',
        'sore', 'wound', 'painful', 'walking problem',
        // Hindi keywords
        'मुंह', 'पैर', 'छाले', 'लंगड़ा', 'बुखार', 'लार', 'जख्म',
        'मुंह में छाले', 'पैर में छाले', 'चल नहीं सकता', 'मुंह का रोग',
        'पैर का रोग', 'खुर', 'दर्द', 'चलने में परेशानी',
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
        // English keywords
        'mastitis', 'udder', 'swelling', 'milk', 'clots', 'blood in milk',
        'yellow milk', 'udder pain', 'hot udder', 'udder infection',
        'swollen udder', 'clotted milk', 'thane', 'milk problem',
        'udder hard', 'udder red', 'milk abnormal',
        // Hindi keywords
        'थन', 'थन में सूजन', 'दूध', 'दूध में खून', 'थन में दर्द',
        'थन गर्म', 'थन सख्त', 'थन लाल', 'दूध में गांठ', 'थन का रोग',
        'मास्टिटिस', 'दूध कम', 'थन में सूजन', 'थन में संक्रमण',
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
        // English keywords
        'lumpy', 'skin', 'nodules', 'lumps', 'swelling', 'lumpy skin',
        'body lumps', 'skin infection', 'fever with lumps', 'eye discharge',
        'nose discharge', 'ticks disease', 'skin bumps', 'skin lesions',
        'skin nodules', 'body bumps',
        // Hindi keywords
        'गांठ', 'चमड़ी', 'चमड़ी पर गांठ', 'शरीर पर गांठ', 'बुखार गांठ',
        'चमड़ी का रोग', 'गांठ वाला रोग', 'आंख से पानी', 'नाक से पानी',
        'चमड़ी में गांठ', 'शरीर में गांठ', 'त्वचा रोग', 'लंपी स्किन',
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
        // English keywords
        'abortion', 'aborted', 'retained placenta', 'infertility',
        'weak calf', 'stillborn', 'breeding problem', 'miscarriage',
        'pregnancy loss', 'cannot conceive', 'reproductive problem',
        // Hindi keywords
        'गर्भपात', 'गर्भ गिर गया', 'बछड़ा कमजोर', 'गर्भधारण नहीं',
        'प्रजनन समस्या', 'बांझपन', 'गर्भ नहीं रुकता', 'बछड़ा मर गया',
        'गर्भाशय समस्या', 'प्रजनन रोग',
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
        // English keywords
        'sudden death', 'died suddenly', 'bloody discharge', 'swollen neck',
        'difficulty breathing', 'convulsions', 'high fever', 'breathing problem',
        'neck swelling', 'blood discharge', 'emergency',
        // Hindi keywords
        'अचानक मौत', 'मर गया', 'गर्दन में सूजन', 'सांस लेने में परेशानी',
        'बुखार', 'खून निकल रहा', 'आपातकाल', 'गर्दन सूजी', 'सांस की समस्या',
      ],
    ),
    Disease(
      name: 'Blackleg',
      symptoms: [
        'Sudden lameness',
        'Swelling in leg muscles',
        'High fever',
        'Loss of appetite',
        'Rapid breathing',
      ],
      keywords: [
        // English keywords
        'blackleg', 'leg swelling', 'muscle swelling', 'sudden lameness',
        'leg pain', 'cannot stand', 'leg problem', 'muscle problem',
        // Hindi keywords
        'पैर में सूजन', 'पैर में दर्द', 'खड़ा नहीं हो सकता', 'पैर का रोग',
        'मांसपेशी में सूजन', 'पैर में गांठ', 'लंगड़ा', 'पैर में समस्या',
      ],
    ),
    Disease(
      name: 'Tuberculosis',
      symptoms: [
        'Chronic cough',
        'Weight loss',
        'Weakness',
        'Difficulty breathing',
        'Reduced milk production',
      ],
      keywords: [
        // English keywords
        'tuberculosis', 'tb', 'cough', 'chronic cough', 'weight loss',
        'weakness', 'breathing problem', 'persistent cough', 'thin',
        // Hindi keywords
        'टीबी', 'खांसी', 'लगातार खांसी', 'वजन कम', 'कमजोरी',
        'सांस की समस्या', 'पतला', 'दुबला', 'टीबी रोग',
      ],
    ),
    Disease(
      name: 'Diarrhea',
      symptoms: [
        'Watery stools',
        'Frequent defecation',
        'Dehydration',
        'Loss of appetite',
        'Weakness',
      ],
      keywords: [
        // English keywords
        'diarrhea', 'diarrhoea', 'loose motion', 'watery stool', 'frequent stool',
        'dehydration', 'stomach problem', 'digestive problem', 'dysentery',
        // Hindi keywords
        'दस्त', 'पतला दस्त', 'बार-बार दस्त', 'पेट खराब', 'पाचन समस्या',
        'पानी जैसा दस्त', 'दस्त लग रहे', 'पेट का रोग', 'अतिसार',
      ],
    ),
    Disease(
      name: 'Pneumonia',
      symptoms: [
        'Cough',
        'Difficulty breathing',
        'Fever',
        'Nasal discharge',
        'Loss of appetite',
      ],
      keywords: [
        // English keywords
        'pneumonia', 'cough', 'breathing problem', 'difficulty breathing',
        'nasal discharge', 'nose discharge', 'lung problem', 'respiratory problem',
        // Hindi keywords
        'निमोनिया', 'खांसी', 'सांस लेने में परेशानी', 'नाक से पानी',
        'फेफड़े का रोग', 'सांस की बीमारी', 'खांसी बुखार', 'सांस फूलना',
      ],
    ),
  ];

  /// Identify disease from symptom text with confidence scoring
  /// Supports both English and Hindi input
  DiseaseIdentification? identifyDisease(String transcribedText) {
    if (transcribedText.isEmpty) return null;
    
    final lowerText = transcribedText.toLowerCase().trim();
    final matches = <DiseaseMatch>[];
    
    // Clean text: remove punctuation and normalize spaces
    final cleanedText = lowerText.replaceAll(RegExp(r'[^\w\s\u0900-\u097F]'), ' ').replaceAll(RegExp(r'\s+'), ' ');
    
    // Split text into words for better matching
    final words = cleanedText.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
    
    print('🔍 Analyzing text: "$cleanedText"');
    print('🔍 Words: $words');
    
    for (final disease in _diseases) {
      int matchCount = 0;
      final matchedKeywords = <String>[];
      double weightedScore = 0.0;
      
      for (final keyword in disease.keywords) {
        final lowerKeyword = keyword.toLowerCase().trim();
        if (lowerKeyword.isEmpty) continue;
        
        // Exact phrase match (highest weight - for multi-word keywords)
        if (lowerKeyword.contains(' ') && cleanedText.contains(lowerKeyword)) {
          matchCount++;
          if (!matchedKeywords.contains(keyword)) {
            matchedKeywords.add(keyword);
          }
          weightedScore += 3.0; // Multi-word matches are very specific
          continue;
        }
        
        // Single word exact match
        if (!lowerKeyword.contains(' ') && cleanedText.contains(RegExp(r'\b' + RegExp.escape(lowerKeyword) + r'\b'))) {
          matchCount++;
          if (!matchedKeywords.contains(keyword)) {
            matchedKeywords.add(keyword);
          }
          weightedScore += 2.0;
          continue;
        }
        
        // Partial word match (for single words)
        if (!lowerKeyword.contains(' ')) {
          for (final word in words) {
            if (word.length >= 3) {
              // Check if keyword contains word or word contains keyword
              if (lowerKeyword.contains(word) || word.contains(lowerKeyword)) {
                matchCount++;
                if (!matchedKeywords.contains(keyword)) {
                  matchedKeywords.add(keyword);
                }
                weightedScore += 1.0; // Partial match gets lower weight
                break;
              }
            }
          }
        }
      }
      
      if (matchCount > 0) {
        // Calculate confidence: more matches = higher confidence
        // Base confidence from weighted score
        final totalPossibleScore = disease.keywords.length * 2.0; // Average weight
        final baseConfidence = (weightedScore / totalPossibleScore * 100).clamp(0.0, 100.0);
        
        // Boost confidence based on match ratio
        final matchRatio = matchCount / disease.keywords.length;
        final confidence = (baseConfidence * (1 + matchRatio * 0.5)).clamp(0.0, 100.0);
        
        print('✅ ${disease.name}: $matchCount matches, confidence: ${confidence.toStringAsFixed(1)}%');
        print('   Matched: ${matchedKeywords.take(5).join(", ")}');
        
        // Lower threshold: accept if at least 1 match with 15% confidence OR 2+ matches
        if (confidence >= 15.0 || matchCount >= 2) {
          matches.add(DiseaseMatch(
            disease: disease,
            confidence: confidence,
            matchedKeywords: matchedKeywords,
          ));
        }
      }
    }
    
    if (matches.isEmpty) {
      print('❌ No disease matches found');
      return null;
    }
    
    // Sort by confidence and return top match
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    final topMatch = matches.first;
    
    print('🏆 Top match: ${topMatch.disease.name} (${topMatch.confidence.toStringAsFixed(1)}%)');
    
    // Very low threshold: accept if confidence >= 10% OR if we have any matches
    // This ensures we show results even with low confidence
    if (topMatch.confidence < 10.0 && matches.length == 1 && topMatch.matchedKeywords.length < 2) {
      print('⚠️ Confidence too low: ${topMatch.confidence.toStringAsFixed(1)}% (${topMatch.matchedKeywords.length} keywords)');
      return null;
    }
    
    print('✅ Returning disease identification: ${topMatch.disease.name}');
    return DiseaseIdentification(
      disease: topMatch.disease,
      confidence: topMatch.confidence,
      matchedKeywords: topMatch.matchedKeywords,
      allMatches: matches.map((m) => m.disease).toList(),
    );
  }
  
  /// Get all possible diseases (for reference)
  List<Disease> getAllDiseases() {
    return List.unmodifiable(_diseases);
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


