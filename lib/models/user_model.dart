import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String rollNumber;

  @HiveField(3)
  final String? currentHostel;

  UserModel({
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.currentHostel,
  });
}
