import 'package:cloud_firestore_platform_interface/src/timestamp.dart';

class ModelAccount {
  late final String businessName;
  final String email;
  final String phoneNumber;
  final String address;
  var image;

  ModelAccount({
    required this.businessName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required Timestamp updatedAt,
    required String id,
    required this.image,
  });
}
