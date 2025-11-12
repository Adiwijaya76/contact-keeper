// lib/features/contacts/contact_detail_page.dart
//
// ============================
// ContactDetailPage (Flutter + Riverpod)
// ============================
// - Halaman detail kontak dengan header melengkung (SliverAppBar.large),
//   avatar besar (Hero), nama, usia otomatis (berdasarkan birthDate),
//   dan 3 kartu informasi (telepon, alamat, tanggal lahir).
// - Animasi ringan: fade + slide pada header, FAB masuk (scale + slide).
// - Menggunakan Color.withValues(...) untuk menghindari API deprecated.
// - ConsumerWidget dipertahankan agar konsisten dengan pola Riverpod,
//   meskipun untuk saat ini tidak membaca provider apa pun di halaman ini.
//
// Catatan Tuning Layout:
// - Ubah konstanta di bawah (headerExoanded, headerBottom, CONTENT_SPACER, EXTRA)
//   bila ingin menyesuaikan jarak/proporsi header terhadap konten.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/contact.dart';
import '../../widgets/contact_avatar.dart';
import 'contact_form_page.dart';

// ===== Konstanta Tuning Header/Kontainer =====
const double headerExoanded = 230;
const double headerBottom   = 16;
const double contentSpacer  = 44;
const double extra           = 20; // naikkan bila ingin lebih longgar

class ContactDetailPage extends ConsumerWidget {
  const ContactDetailPage({super.key, required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final cs = Theme.of(context).colorScheme;

    // Format tanggal lahir dd-MM-yyyy
    final birth = '${contact.birthDate.day.toString().padLeft(2, '0')}-'
        '${contact.birthDate.month.toString().padLeft(2, '0')}-'
        '${contact.birthDate.year}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ===== AppBar Besar dengan Header Avatar + Nama + Usia =====
          SliverAppBar.large(
            pinned: true,
            expandedHeight: headerExoanded + extra,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            clipBehavior: Clip.none,
            leading: IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            flexibleSpace: Stack(
              clipBehavior: Clip.none,
              children: [
                // Header (avatar + nama + usia) dengan animasi fade+slide ringan
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: headerBottom,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, t, child) => Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 8),
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: 'avatar_${contact.id}',
                          child: ContactAvatar(
                            name: contact.name,
                            url: contact.avatarUrl,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            contact.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Usia ${contact.ageYears} tahun — $birth',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer agar konten tidak menabrak header
          const SliverToBoxAdapter(child: SizedBox(height: contentSpacer + extra)),

          // ===== Kartu-kartu Informasi =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.list(
              children: [
                _InfoCard(
                  icon: Icons.phone_rounded,
                  iconColor: cs.primary,
                  label: 'Nomor Telepon',
                  value: contact.phone.isEmpty ? '-' : contact.phone,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.home_rounded,
                  iconColor: cs.tertiary,
                  label: 'Alamat',
                  value: contact.address.isEmpty ? '-' : contact.address,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.calendar_today_rounded,
                  iconColor: cs.secondary,
                  label: 'Tanggal Lahir',
                  value: birth,
                ),
                const SizedBox(height: 96), // ruang untuk FAB
              ],
            ),
          ),
        ],
      ),

      // ===== FAB Edit (animasi scale + slide) =====
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        tween: Tween(begin: .92, end: 1),
        builder: (context, s, child) => Transform.translate(
          offset: const Offset(0, 6) * (1 - s),
          child: Transform.scale(scale: s, child: child),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 220),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (_, __, ___) => ContactFormPage(existing: contact),
                transitionsBuilder: (context, anim, __, child) {
                  final curved = CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                    reverseCurve: Curves.easeIn,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(curved),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Kontak'),
          elevation: 3,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ======================= SUBWIDGET: Info Card =======================
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon dalam chip lembut
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .12), // pengganti withOpacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Label + Nilai
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
