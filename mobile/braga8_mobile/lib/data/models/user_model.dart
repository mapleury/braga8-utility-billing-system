import 'unit_model.dart';

class UserModel {
  final String username;
  final String email;
  final String joinDate;

  final String tenantName;
  final String phone;
  final String businessType;
  final String companyName;

  final List<Unit> units;

  UserModel({
    required this.username,
    required this.email,
    required this.joinDate,
    required this.tenantName,
    required this.phone,
    required this.businessType,
    required this.companyName,
    required this.units,
  });

  String? get token => null;
}