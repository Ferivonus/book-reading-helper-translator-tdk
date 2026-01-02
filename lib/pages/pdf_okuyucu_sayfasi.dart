import 'dart:io';
import 'package:book_reader/service/db/db_service.dart';
import 'package:book_reader/service/tdk-service/tdk-service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfOkuyucuSayfasi extends StatefulWidget {
  final String pdfPath;
  const PdfOkuyucuSayfasi({super.key, required this.pdfPath});

  @override
  State<PdfOkuyucuSayfasi> createState() => _PdfOkuyucuSayfasiState();
}

class _PdfOkuyucuSayfasiState extends State<PdfOkuyucuSayfasi> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  double _fontSize = 18.0;
  bool _isTextMode = false;
  bool _isDarkMode = false;
  String _extractedText = "Metin hazırlanıyor...";
  bool _isTextLoading = true;

  // Seçilen metni tutmak için değişken
  String? _seciliMetin;

  int _toplamSayfa = 0;
  int _mevcutSayfa = 0;

  @override
  void initState() {
    super.initState();
    _metniHazirla();
  }

  Future<void> _metniHazirla() async {
    try {
      final List<int> bytes = File(widget.pdfPath).readAsBytesSync();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      if (mounted) {
        setState(() {
          _extractedText = text;
          _isTextLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _extractedText = "Metin ayıklanamadı. PDF modunda devam edin.";
          _isTextLoading = false;
        });
      }
    }
  }

  void _sozlukModaliniGoster(String kelime) {
    if (kelime.isEmpty) return;

    // Modalı açmadan önce seçimi temizle/butonu gizle
    setState(() {
      _seciliMetin = null;
    });
    _pdfViewerController.clearSelection();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: _isDarkMode
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF8F9FA),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: TdkService.kelimeAra(kelime),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data != null) {
                DbService.gecmiseEkle(snapshot.data!['madde']);
                return _buildDictionaryUI(snapshot.data!, scrollController);
              }
              return _buildErrorState(kelime, scrollController);
            },
          ),
        ),
      ),
    );
  }

  // --- SAYFAYA GİT DİYALOĞU ---
  void _sayfayaGitPenceresi() {
    TextEditingController pageController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          "Sayfaya Git",
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "1 - $_toplamSayfa arası",
            hintStyle: TextStyle(
              color: _isDarkMode ? Colors.white54 : Colors.grey,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              int? page = int.tryParse(pageController.text);
              if (page != null && page > 0 && page <= _toplamSayfa) {
                _pdfViewerController.jumpToPage(page);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Git"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode
        ? const Color(0xFF121212)
        : (_isTextMode ? const Color(0xFFFDF6E3) : const Color(0xFFF5F5F5));
    final textColor = _isDarkMode
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF2B2B2B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
        elevation: 1,
        title: Text(
          widget.pdfPath.split(Platform.pathSeparator).last,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          InkWell(
            onTap: _isTextMode ? null : _sayfayaGitPenceresi,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Center(
                child: Text(
                  _isTextMode ? "Metin" : "$_mevcutSayfa / $_toplamSayfa",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          if (_isTextMode)
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
          IconButton(
            icon: Icon(_isTextMode ? Icons.picture_as_pdf : Icons.text_fields),
            onPressed: () => setState(() {
              _isTextMode = !_isTextMode;
              _seciliMetin = null; // Mod değişince seçimi temizle
            }),
          ),
          if (_isTextMode) ...[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () =>
                  setState(() => _fontSize = (_fontSize - 2).clamp(10, 40)),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  setState(() => _fontSize = (_fontSize + 2).clamp(10, 40)),
            ),
          ],
        ],
      ),
      // STACK KULLANIYORUZ: PDF/Metin altta, Buton üstte
      body: Stack(
        children: [
          // 1. İÇERİK KATMANI
          _isTextMode ? _buildTextMode(bgColor, textColor) : _buildPdfMode(),

          // 2. BUTON KATMANI (PDF MODU İÇİN)
          // Text modu kendi context menüsünü kullanır, PDF modu için özel buton ekliyoruz.
          if (!_isTextMode && _seciliMetin != null && _seciliMetin!.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: () => _sozlukModaliniGoster(_seciliMetin!),
                  backgroundColor: Colors.indigo,
                  icon: const Icon(Icons.menu_book, color: Colors.white),
                  label: const Text(
                    "Anlamı Gör",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 1. METİN OKUMA MODU ---
  Widget _buildTextMode(Color bg, Color textC) {
    if (_isTextLoading) return const Center(child: CircularProgressIndicator());

    return SelectionArea(
      // Metin seçim menüsünü özelleştiriyoruz
      contextMenuBuilder: (context, selectableRegionState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: selectableRegionState.contextMenuAnchors,
          buttonItems: [
            ContextMenuButtonItem(
              label: 'Anlamı Gör',
              onPressed: () {
                // Seçili metni al
                final selectedText = selectableRegionState
                    .textEditingValue
                    .selection
                    .textInside(selectableRegionState.textEditingValue.text);
                if (selectedText.isNotEmpty) {
                  _sozlukModaliniGoster(selectedText.trim());
                  selectableRegionState.hideToolbar();
                }
              },
            ),
          ],
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Text(
          _extractedText,
          style: TextStyle(
            fontSize: _fontSize,
            height: 1.6,
            color: textC,
            fontFamily: 'Georgia',
          ),
        ),
      ),
    );
  }

  // --- 2. PDF MODU ---
  Widget _buildPdfMode() {
    return SfPdfViewer.file(
      File(widget.pdfPath),
      key: _pdfViewerKey,
      controller: _pdfViewerController,
      initialZoomLevel: 1.5,
      pageSpacing: 4,

      // Metin seçildiğinde çalışır
      onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
        setState(() {
          // Eğer seçim varsa ve 1 karakterden uzunsa butonu göstermek için state'i güncelle
          if (details.selectedText != null &&
              details.selectedText!.trim().length > 1) {
            _seciliMetin = details.selectedText!.trim();
          } else {
            _seciliMetin = null;
          }
        });
      },

      onDocumentLoaded: (details) {
        setState(() => _toplamSayfa = details.document.pages.count);
        int lastPage = DbService.sonSayfayiGetir(widget.pdfPath);
        if (lastPage > 1) {
          Future.delayed(
            const Duration(milliseconds: 300),
            () => _pdfViewerController.jumpToPage(lastPage),
          );
        }
      },
      onPageChanged: (details) {
        setState(() => _mevcutSayfa = details.newPageNumber);
        DbService.sonSayfayiKaydet(widget.pdfPath, details.newPageNumber);
      },
    );
  }

  // --- SÖZLÜK UI ---
  Widget _buildDictionaryUI(Map<String, dynamic> veri, ScrollController sc) {
    final madde = veri['madde'];
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildHeader(madde, veri['lisan']),
              const SizedBox(height: 20),
              Text(
                "ANLAMLAR",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.grey : Colors.grey.shade600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              ...(veri['anlamlarListe'] as List)
                  .asMap()
                  .entries
                  .map((e) => _buildMeaningCard(e.key + 1, e.value))
                  .toList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String madde, String? lisan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              madde,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _isDarkMode
                    ? Colors.indigoAccent
                    : const Color(0xFF1A237E),
              ),
            ),
            _buildFavButton(madde),
          ],
        ),
        if (lisan != null && lisan.isNotEmpty)
          Text(
            lisan,
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.blueGrey.shade400,
            ),
          ),
      ],
    );
  }

  Widget _buildFavButton(String kelime) {
    return StatefulBuilder(
      builder: (c, st) {
        bool isFav = DbService.favoriMi(kelime);
        return IconButton(
          icon: Icon(
            isFav ? Icons.bookmark : Icons.bookmark_border,
            color: isFav
                ? Colors.orangeAccent
                : (_isDarkMode ? Colors.grey : Colors.grey.shade400),
            size: 32,
          ),
          onPressed: () {
            DbService.favoriEkleCikar(kelime);
            st(() {});
          },
        );
      },
    );
  }

  Widget _buildMeaningCard(int idx, dynamic data) {
    String? type;
    if (data['ozelliklerListe'] != null &&
        (data['ozelliklerListe'] as List).isNotEmpty) {
      type = data['ozelliklerListe'][0]['tam_adi'];
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode ? Colors.transparent : Colors.grey.shade200,
        ),
        boxShadow: _isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: Text(
                  "$idx",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (type != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.toLowerCase(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['anlam'] ?? "",
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w400,
              color: _isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String k, ScrollController sc) => ListView(
    controller: sc,
    children: [
      const SizedBox(height: 50),
      const Icon(Icons.search_off, size: 80, color: Colors.grey),
      Center(
        child: Text(
          "'$k'",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          "Sözlükte bulunamadı.",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    ],
  );
}
