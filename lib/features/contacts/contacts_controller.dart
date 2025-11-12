// ===========================================================
// lib/features/contacts/contacts_controller.dart (Riverpod 3)
// ===========================================================
// - Tanpa flutter_riverpod/legacy.dart
// - AsyncNotifier<List<Contact>> untuk state utama
// - Helper privat _sorted() agar DRY dan konsisten
// - Operasi add/update/remove pakai AsyncValue.guard()
//   supaya error terpropagasi dan UI bisa menampilkan error state
// - reload() menjaga UX (loading singkat) dan konsistensi
// - filteredContactsProvider tetap kompatibel dengan UI saat ini
// ===========================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/contacts_repository_hive.dart';
import '../../models/contact.dart';

/// Repository provider (singleton yang dikelola Riverpod).
final contactsRepositoryProvider =
    Provider<ContactsRepositoryHive>((ref) => ContactsRepositoryHive());

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  late final ContactsRepositoryHive _repo;

  @override
  Future<List<Contact>> build() async {
    _repo = ref.read(contactsRepositoryProvider);
    return _load();
  }

  Future<List<Contact>> _load() async {
    final data = await _repo.getAll();
    return _sorted(data);
  }

  List<Contact> _sorted(List<Contact> list) {
    // Sort by name (case-insensitive agar lebih natural)
    final copy = [...list];
    copy.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return copy;
  }

  /// Force refresh dari sumber data utama.
  Future<void> reload() async {
    // Tampilkan loading singkat agar ada feedback ke user
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Factory contact kosong untuk form tambah.
  Contact blank() => Contact(
        id: _newId(),
        name: '',
        phone: '',
        address: '',
        birthDate: DateTime(2000, 1, 1),
      );

  /// Tambah contact baru.
  Future<void> add(Contact c) async {
    state = await AsyncValue.guard(() async {
      await _repo.insert(c);
      // Ambil state terbaru (kalau belum ada data, load dulu)
      final current = switch (state) {
        AsyncData<List<Contact>>(:final value) => value,
        _ => await _load(),
      };
      return _sorted([...current, c]);
    });
  }

  /// Update contact (by id).
  Future<void> updateContact(Contact c) async {
    state = await AsyncValue.guard(() async {
      await _repo.update(c);
      final current = switch (state) {
        AsyncData<List<Contact>>(:final value) => value,
        _ => await _load(),
      };
      final updated = [
        for (final x in current) if (x.id == c.id) c else x,
      ];
      return _sorted(updated);
    });
  }

  /// Hapus contact (by id).
  Future<void> remove(String id) async {
    state = await AsyncValue.guard(() async {
      await _repo.delete(id);
      final current = switch (state) {
        AsyncData<List<Contact>>(:final value) => value,
        _ => await _load(),
      };
      final updated = [for (final x in current) if (x.id != id) x];
      // Tidak perlu sort ulang karena urutan selain yang dihapus tetap sama.
      return updated;
    });
  }
}

/// Provider utama daftar kontak (async).
final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(ContactsNotifier.new);

/// Query pencarian (nama/telepon/alamat).
final queryProvider = StateProvider<String>((ref) => '');

/// Daftar kontak terfilter oleh queryProvider.
final filteredContactsProvider = Provider<AsyncValue<List<Contact>>>((ref) {
  final listAsync = ref.watch(contactsProvider);
  final q = ref.watch(queryProvider).trim().toLowerCase();

  return listAsync.whenData((list) {
    if (q.isEmpty) return list;
    return list.where((c) {
      final name = c.name.toLowerCase();
      final phone = c.phone.toLowerCase();
      final address = c.address.toLowerCase();
      return name.contains(q) || phone.contains(q) || address.contains(q);
    }).toList();
  });
});
