import 'dart:convert';
import 'package:http/http.dart' as http;

class TdkService {
  static Future<Map<String, dynamic>?> kelimeAra(String kelime) async {
    // 1. Temizlik: Sadece harf ve rakamları tut (Tırnaklar burada kesin gider)
    String cleanWord = kelime.replaceAll(
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true),
      '',
    );

    // 2. Türkçe Karakter Manuel Fix
    final Map<String, String> turkishMap = {
      'İ': 'i',
      'I': 'ı',
      'Ç': 'ç',
      'Ğ': 'ğ',
      'Ö': 'ö',
      'Ş': 'ş',
      'Ü': 'ü',
    };
    turkishMap.forEach(
      (key, value) => cleanWord = cleanWord.replaceAll(key, value),
    );

    // Küçük harfe çevir ve boşlukları at
    cleanWord = cleanWord.toLowerCase().trim();

    // Debug: Kelimenin tam olarak nasıl gittiğini konsolda gör (Sonra silebilirsin)
    // debugPrint("TDK Sorgusu: |$cleanWord|");

    if (cleanWord.isEmpty) return null;

    try {
      final url = Uri.https('sozluk.gov.tr', '/gts', {'ara': cleanWord});

      // 3. TARAYICI GİBİ DAVRAN (En Önemli Kısım)
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          final firstResult = data[0];
          if (firstResult is Map<String, dynamic> &&
              firstResult.containsKey('madde')) {
            return firstResult;
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
