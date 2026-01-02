import 'package:book_reader/service/db/db_service.dart';
import 'package:book_reader/service/tdk-service/tdk-service.dart';
import 'package:flutter/material.dart';

class GecmisSayfasi extends StatelessWidget {
  const GecmisSayfasi({super.key});

  // Geçmişteki bir kelimeye tıklandığında anlamını gösteren modal
  void _anlaminiGoster(BuildContext context, String kelime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: FutureBuilder(
            future: TdkService.kelimeAra(kelime),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                var veri = snapshot.data!;
                return ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      veri['madde'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ...(veri['anlamlarListe'] as List)
                        .map(
                          (a) => ListTile(
                            leading: const Icon(Icons.arrow_right),
                            title: Text(a['anlam']),
                          ),
                        )
                        .toList(),
                  ],
                );
              }
              return const Center(child: Text("Kelime bilgisi alınamadı."));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DbService üzerinden geçmişi alıyoruz
    final List<String> gecmisListesi = DbService.gecmisiGetir();

    return Scaffold(
      appBar: AppBar(title: const Text("Arama Geçmişi"), centerTitle: true),
      body: gecmisListesi.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Henüz bir kelime aramadınız.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: gecmisListesi.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final String kelime = gecmisListesi[index];
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.blueGrey),
                  title: Text(kelime),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _anlaminiGoster(context, kelime),
                );
              },
            ),
    );
  }
}
