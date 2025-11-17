import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String _baseUrl = 'https://libretranslate.de/translate';

  Future<String> translate(
    String text,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['translatedText'];
      } else {
        throw Exception('Failed to translate text');
      }
    } catch (e) {
      throw Exception('Failed to connect to the translation service');
    }
  }
}
