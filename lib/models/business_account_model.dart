class BusinessAccountModel {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String description;
  final String openingHour;
  final String businesstype;
  final String photoUrl;
  final String user_id;

  BusinessAccountModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.description,
    required this.openingHour,
    required this.businesstype,
    required this.photoUrl,
    required this.user_id,
    required String closing_hour,
    required String opening_hour,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'phone': phone,
    'email': email,
    'description': description,
    'openingHour': openingHour,
    'businesstype': businesstype,
    'photoUrl': photoUrl,
    'user_id': user_id,
  };

  factory BusinessAccountModel.fromJson(Map<String, dynamic> json) {
    return BusinessAccountModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      description: json['description'] ?? '',
      openingHour: json['openingHour'] ?? '',
      businesstype: json['businesstype'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      user_id: json['user_id'] ?? '',
      closing_hour: '',
      opening_hour: '',
    );
  }
}
