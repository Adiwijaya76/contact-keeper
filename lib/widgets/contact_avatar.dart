// ===========================================================
// lib/widgets/contact_avatar.dart (Refactor & Dokumentasi)
// ===========================================================
// Komponen avatar kontak dengan fallback inisial nama.
// -----------------------------------------------------------
// Fitur:
// - Menampilkan gambar profil dari URL jika tersedia.
// - Bila URL kosong/error → tampilkan lingkaran warna stabil
//   dengan inisial huruf nama.
// - Warna background dihasilkan konsisten dari hash nama.
// - Mendukung ukuran dinamis (default 44).
// ===========================================================

import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.name,
    this.url,
    this.size = 44,
  });

  /// Nama lengkap kontak (digunakan untuk inisial & warna latar)
  final String name;

  /// URL foto avatar (opsional, fallback jika kosong/error)
  final String? url;

  /// Ukuran diameter avatar (default: 44)
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final cs = Theme.of(context).colorScheme;
    final bg = _stableBgFrom(name, cs);

    /// Widget fallback (inisial di dalam lingkaran warna)
    Widget fallback() => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: size * 0.42,
              color: cs.onPrimary,
            ),
          ),
        );

    // Jika URL kosong atau null, langsung fallback.
    if (url == null || url!.isEmpty) return fallback();

    // Jika URL ada → tampilkan image network dengan cache & fallback error
    return ClipOval(
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
        // Cache kecil agar lebih efisien di daftar kontak
        cacheWidth: (size * 2).toInt(),
        cacheHeight: (size * 2).toInt(),
      ),
    );
  }

  // ===========================================================
  // Utility: Ambil inisial dari nama
  // ===========================================================
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '#';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    // Dua huruf pertama dari dua kata pertama
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // ===========================================================
  // Utility: Pilih warna latar stabil dari hash nama
  // ===========================================================
  static Color _stableBgFrom(String key, ColorScheme cs) {
    // Palet warna dasar (urutkan agar konsisten)
    final palette = <Color>[
      cs.primary,
      cs.secondary,
      cs.tertiary,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
    ];

    // Hash sederhana berbasis kode karakter
    final hash = key.codeUnits.fold<int>(
      0,
      (acc, code) => (acc * 31 + code) & 0x7fffffff,
    );

    // Pilih warna berdasarkan sisa hasil modulo panjang palet
    return palette[hash % palette.length];
  }
}
