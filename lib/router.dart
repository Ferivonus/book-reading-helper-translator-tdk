import 'package:book_reader/pages/home_screen.dart';
import 'package:book_reader/pages/online_pdf_okuyucu_sayfasi.dart';
import 'package:book_reader/pages/pdf_okuyucu_sayfasi.dart';
import 'package:book_reader/pages/gecmis_sayfasi.dart'; // Yeni
import 'package:book_reader/pages/favori_sayfasi.dart'; // Yeni
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/pdf-oku',
      builder: (context, state) {
        final String? filePath = state.extra as String?;
        if (filePath != null) {
          return PdfOkuyucuSayfasi(pdfPath: filePath);
        }
        return const Scaffold(
          body: Center(child: Text("Hata: Dosya yolu yok")),
        );
      },
    ),
    // Geçmiş Sayfası Rotası
    GoRoute(
      path: '/gecmis',
      builder: (context, state) => const GecmisSayfasi(),
    ),
    // Favoriler Sayfası Rotası
    GoRoute(
      path: '/favoriler',
      builder: (context, state) => const FavoriSayfasi(),
    ),
    GoRoute(
      path: '/online-pdf',
      builder: (context, state) =>
          OnlinePdfOkuyucuSayfasi(pdfUrl: state.extra as String),
    ),
  ],
);
