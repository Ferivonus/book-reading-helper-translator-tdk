import 'package:hive_flutter/hive_flutter.dart';

class DbService {
  static const String favoriBoxName = "favoriler";
  static const String gecmisBoxName = "gecmis";
  static const String sonSayfalarBoxName = "son_sayfalar";

  /// Hive kutularını hazırlar ve uygulamayı başlatır.
  static Future<void> altYapiHazirla() async {
    await Hive.initFlutter();

    // Kelimeleri saklamak için String kutuları
    await Hive.openBox<String>(favoriBoxName);
    await Hive.openBox<String>(gecmisBoxName);

    // Sayfa numaralarını (int) dosya yoluna (String) göre saklamak için kutu
    await Hive.openBox<int>(sonSayfalarBoxName);
  }

  // --- FAVORİ İŞLEMLERİ ---

  /// Tüm favori kelimeleri liste olarak döner.
  static List<String> favorileriGetir() =>
      Hive.box<String>(favoriBoxName).values.toList();

  /// Kelime favorilerde varsa siler, yoksa ekler.
  static void favoriEkleCikar(String kelime) {
    var box = Hive.box<String>(favoriBoxName);
    if (box.values.contains(kelime)) {
      final key = box.keys.firstWhere((k) => box.get(k) == kelime);
      box.delete(key);
    } else {
      box.add(kelime);
    }
  }

  /// Kelimenin favori olup olmadığını kontrol eder.
  static bool favoriMi(String kelime) =>
      Hive.box<String>(favoriBoxName).values.contains(kelime);

  // --- GEÇMİŞ İŞLEMLERİ ---

  /// Arama geçmişini son eklenen en üstte olacak şekilde döner.
  static List<String> gecmisiGetir() =>
      Hive.box<String>(gecmisBoxName).values.toList().reversed.toList();

  /// Kelimeyi geçmişe ekler (Aynı kelime üst üste eklenmez, limit 50).
  static void gecmiseEkle(String kelime) {
    var box = Hive.box<String>(gecmisBoxName);
    if (box.isNotEmpty && box.values.last == kelime) return;
    box.add(kelime);
    if (box.length > 50) box.deleteAt(0);
  }

  // --- SON SAYFA TAKİBİ (YENİ) ---

  /// PDF dosya yoluna göre en son kalınan sayfa numarasını kaydeder.
  static Future<void> sonSayfayiKaydet(String pdfPath, int sayfaNo) async {
    var box = Hive.box<int>(sonSayfalarBoxName);
    await box.put(pdfPath, sayfaNo);
  }

  /// PDF dosya yoluna göre kalınan sayfayı getirir (Kayıt yoksa 1 döner).
  static int sonSayfayiGetir(String pdfPath) {
    var box = Hive.box<int>(sonSayfalarBoxName);
    return box.get(pdfPath, defaultValue: 1) ?? 1;
  }
}
