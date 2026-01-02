import 'package:book_reader/service/db/db_service.dart';
import 'package:book_reader/service/tdk-service/tdk-service.dart';
import 'package:flutter/material.dart';

class FavoriSayfasi extends StatefulWidget {
  const FavoriSayfasi({super.key});

  @override
  State<FavoriSayfasi> createState() => _FavoriSayfasiState();
}

class _FavoriSayfasiState extends State<FavoriSayfasi> {
  // Kelimeye tıklandığında anlamını gösteren modal fonksiyonu
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
                        color: Colors.indigo,
                      ),
                    ),
                    const Divider(),
                    ...(veri['anlamlarListe'] as List)
                        .map(
                          (a) => ListTile(
                            leading: const Icon(
                              Icons.bookmark_border,
                              size: 20,
                            ),
                            title: Text(a['anlam'] ?? ""),
                          ),
                        )
                        .toList(),
                  ],
                );
              }
              return const Center(child: Text("Bilgi alınamadı."));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build metodu içinde veriyi her seferinde taze alıyoruz
    final favoriListesi = DbService.favorileriGetir();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori Kelimelerim"),
        centerTitle: true,
      ),
      body: favoriListesi.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star_outline, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Henüz favori kelimeniz yok.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: favoriListesi.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final kelime = favoriListesi[index];
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text(
                    kelime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: Colors.redAccent,
                    ),
                    tooltip: "Favorilerden Kaldır",
                    onPressed: () {
                      setState(() {
                        DbService.favoriEkleCikar(kelime);
                      });
                      // Silme sonrası küçük bir bildirim (isteğe bağlı)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$kelime favorilerden kaldırıldı"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () => _anlaminiGoster(context, kelime),
                );
              },
            ),
    );
  }
}
