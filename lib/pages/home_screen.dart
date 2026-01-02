import 'package:book_reader/service/permission_activator/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // PDF seçme ve okuyucuya yönlendirme fonksiyonu
  Future<void> _pdfSecVeAc(BuildContext context) async {
    bool isGranted = await PermissionService.requestStoragePermission();

    if (isGranted) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          lockParentWindow: true,
        );

        if (result != null && result.files.single.path != null) {
          String path = result.files.single.path!;
          if (context.mounted) {
            context.push('/pdf-oku', extra: path);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error picking file: $e")));
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please grant storage permission to read PDFs."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Sözlük & Okuyucu"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        // İçerik uzarsa kaydırılabilmesi için
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Kısım: PDF Seçme Kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () => _pdfSecVeAc(context),
                  borderRadius: BorderRadius.circular(15),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 60,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Cihazdan PDF Seç",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Okumaya ve öğrenmeye başla",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Kütüphanem & Araçlar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Test PDF'i (İnternetten Örnek Dosya)
              _menuElemani(
                context,
                icon: Icons.cloud_download_outlined,
                color: Colors.purple,
                baslik: "Online Test PDF",
                altBaslik: "Sunucudan döküman yükle",
                rota: '/online-pdf', // Yeni rota adı
                extra:
                    "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
              ),

              _menuElemani(
                context,
                icon: Icons.history,
                color: Colors.blue,
                baslik: "Son Bakılan Kelimeler",
                altBaslik: "Arama geçmişini incele",
                rota: '/gecmis',
              ),
              const SizedBox(height: 10),

              _menuElemani(
                context,
                icon: Icons.star,
                color: Colors.orange,
                baslik: "Favori Kelimelerim",
                altBaslik: "Yıldızladığın kelimeler",
                rota: '/favoriler',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menü elemanları için yardımcı widget
  Widget _menuElemani(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String baslik,
    required String altBaslik,
    required String rota,
    Object? extra, // Navigasyon sırasında gönderilecek ek veri
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          baslik,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(altBaslik),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(rota, extra: extra),
      ),
    );
  }
}
