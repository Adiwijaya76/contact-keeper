import 'package:hive/hive.dart';
import '../models/contact.dart';

class ContactsRepositoryHive {
  Box<Contact> get _box => Hive.box<Contact>('contacts');

  Future<List<Contact>> getAll() async {
    final list = _box.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<void> insert(Contact c) async => _box.put(c.id, c);
  Future<void> update(Contact c) async => _box.put(c.id, c);
  Future<void> delete(String id) async => _box.delete(id);
}
