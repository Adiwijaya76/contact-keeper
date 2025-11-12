// ===========================================================
// lib/features/contacts/contacts_page.dart
// ===========================================================
// Halaman utama daftar kontak dalam aplikasi “Contact Keeper”.
// Menggunakan Riverpod (ConsumerWidget) untuk state management.
// Fitur utama:
// - Menampilkan daftar kontak (nama, telepon, umur).
// - Pencarian (search bar) dan animasi transisi halus.
// - Tombol tambah kontak (FAB) dan aksi edit/hapus.
// - Refresh manual menggunakan AppRefresh (pull-to-refresh).
//
// Menggunakan API modern Flutter (Material 3 + withValues())
// ===========================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/contact.dart';
import '../../widgets/contact_avatar.dart';
import '../../widgets/refresh.dart';
import 'contacts_controller.dart';
import 'contact_form_page.dart';
import 'contact_detail_page.dart';

// ===========================================================
// ROOT WIDGET : ContactsPage
// ===========================================================
class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  // Fungsi refresh daftar kontak dari provider
  Future<void> _refreshList(WidgetRef ref) async {
    await ref.read(contactsProvider.notifier).reload();
    ref.invalidate(filteredContactsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menyimak stream daftar kontak (hasil filter/search)
    final contactsAsync = ref.watch(filteredContactsProvider);

    return Scaffold(
      // Body utama dengan refresh gesture
      body: AppRefresh(
        onRefresh: () async => _refreshList(ref),
        edgeOffset: 120, // jarak top refresh
        child: CustomScrollView(
          slivers: [
            // ===========================================================
            // HEADER UTAMA (SliverAppBar)
            // ===========================================================
            const SliverAppBar.large(
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Contacts',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                titlePadding: EdgeInsets.only(left: 25, bottom: 16),
              ),
            ),

            // ===========================================================
            // AREA SEARCH + JUMLAH KONTAK
            // ===========================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    const _SearchBarWidget(),
                    const SizedBox(height: 8),

                    // Jumlah kontak (menyesuaikan kondisi)
                    contactsAsync.maybeWhen(
                      data: (list) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: list.isEmpty
                            ? const SizedBox.shrink(key: ValueKey('no-count'))
                            : Align(
                                key: const ValueKey('count'),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${list.length} kontak',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // ===========================================================
            // STATE BODY (Loading / Error / Data)
            // ===========================================================
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _BodyState(
                  contactsAsync: contactsAsync,
                  ref: ref,
                  refreshList: _refreshList,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // ===========================================================
      // FAB : Tambah Kontak Baru
      // ===========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(_fadeRoute(const ContactFormPage())),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Kontak'),
        elevation: 3,
      ),
    );
  }
}

// ===========================================================
// BODY STATE : Memproses tampilan Loading / Error / Data
// ===========================================================
class _BodyState extends StatelessWidget {
  const _BodyState({
    required this.contactsAsync,
    required this.ref,
    required this.refreshList,
  });

  final AsyncValue<List<Contact>> contactsAsync;
  final WidgetRef ref;
  final Future<void> Function(WidgetRef) refreshList;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return contactsAsync.when(
      // ---------- Kondisi Loading ----------
      loading: () => SizedBox(
        height: size.height * 0.5,
        child: const Center(child: CircularProgressIndicator()),
      ),

      // ---------- Kondisi Error ----------
      error: (e, _) => SizedBox(
        height: size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),

      // ---------- Kondisi Data ----------
      data: (list) {
        // Jika tidak ada data
        if (list.isEmpty) {
          return SizedBox(
            height: size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_rounded,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3), // non-deprecated
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kontak',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan kontak pertama Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // Jika data tersedia
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Daftar kontak dengan animasi stagger
              for (int i = 0; i < list.length; i++)
                _StaggeredCard(
                  key: ValueKey(list[i].id),
                  index: i,
                  child: _ContactCard(
                    contact: list[i],
                    onOpen: () => Navigator.of(context)
                        .push(_fadeRoute(ContactDetailPage(contact: list[i]))),
                    onEdit: () => Navigator.of(context)
                        .push(_fadeRoute(ContactFormPage(existing: list[i]))),

                    // Hapus kontak dengan dialog konfirmasi
                    onDelete: () async {
                      final ok = await _confirmDelete(context, list[i].name);
                      if (ok == true) {
                        await ref.read(contactsProvider.notifier).remove(list[i].id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kontak "${list[i].name}" dihapus'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                        await refreshList(ref); // sinkronisasi ulang
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================
// _StaggeredCard : Animasikan tiap kartu (fade + slide-in)
// ===========================================================
class _StaggeredCard extends StatefulWidget {
  const _StaggeredCard({required this.index, required this.child, super.key});
  final int index;
  final Widget child;

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    const base = 180; // durasi dasar
    final delay = 32 * widget.index; // efek stagger
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: base + delay.clamp(0, 360)),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_c);

    WidgetsBinding.instance.addPostFrameCallback((_) => _c.forward());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ===========================================================
// _SearchBarWidget : Komponen SearchBar interaktif
// ===========================================================
class _SearchBarWidget extends ConsumerStatefulWidget {
  const _SearchBarWidget();

  @override
  ConsumerState<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<_SearchBarWidget> {
  final _ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctl.text = ref.read(queryProvider); // inisialisasi teks awal
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SearchBar(
      controller: _ctl,
      hintText: 'Cari nama, nomor, atau alamat...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
      ),
      trailing: [
        // Tombol clear hanya muncul jika teks tidak kosong
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _ctl.text.isNotEmpty
              ? IconButton(
                  key: const ValueKey('clear'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _ctl.clear();
                    ref.read(queryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : const SizedBox.shrink(key: ValueKey('no-clear')),
        ),
      ],
      onChanged: (v) {
        ref.read(queryProvider.notifier).state = v;
        setState(() {});
      },
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

// ===========================================================
// _ContactCard : Tampilan satu kontak dalam daftar
// ===========================================================
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Contact contact;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen, // buka detail
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                ContactAvatar(name: contact.name, url: contact.avatarUrl, size: 56),
                const SizedBox(width: 16),

                // Nama, telepon, dan umur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contact.phone,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.cake_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${contact.ageYears} tahun',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Aksi edit dan delete
                Column(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      onPressed: onEdit,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton.outlined(
                      tooltip: 'Delete',
                      icon: Icon(Icons.delete_rounded, size: 20, color: cs.error),
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// DIALOG KONFIRMASI HAPUS KONTAK
// ===========================================================
Future<bool?> _confirmDelete(BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        Icons.delete_outline_rounded,
        size: 32,
        color: Theme.of(ctx).colorScheme.error,
      ),
      title: const Text('Hapus Kontak'),
      content: Text('Yakin menghapus "$name"? Tindakan ini tidak dapat dibatalkan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
            foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
          ),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

// ===========================================================
// _fadeRoute : Helper untuk transisi halaman (fade + slide)
// ===========================================================
PageRoute _fadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}
