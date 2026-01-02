import 'package:book_reader/service/db/db_service.dart';
import 'package:flutter/material.dart';
import 'router.dart';

void main() async {
  // Flutter binding'lerini başlatmak, asenkron (async) işlemlerden önce zorunludur.
  WidgetsFlutterBinding.ensureInitialized();

  // Fonksiyon ismindeki 'ı' harfini 'i' ile değiştirdik
  await DbService.altYapiHazirla();

  runApp(const PdfSozlukApp());
}

class PdfSozlukApp extends StatelessWidget {
  const PdfSozlukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PDF Sözlük',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router, // router.dart'taki yapılandırmayı kullanıyoruz
    );
  }
}
