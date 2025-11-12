import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  final String address;
  @HiveField(4)
  final DateTime birthDate;
  @HiveField(5)
  final String? avatarUrl;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.birthDate,
    this.avatarUrl,
  });

  int get ageYears {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final hadBirthday =
        (now.month > birthDate.month) || (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) years--;
    return years;
  }

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? avatarUrl,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
