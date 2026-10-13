/// Model data pengguna aplikasi CareCycle
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'donatur', 'komunitas', 'admin'
  final String? avatarUrl;
  final String? phoneNumber;
  final String? address;
  final int carePoints;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phoneNumber,
    this.address,
    this.carePoints = 0,
    this.createdAt,
  });

  bool get isDonatur => role == 'donatur';
  bool get isKomunitas => role == 'komunitas';
  bool get isAdmin => role == 'admin';

  String get roleDisplay {
    switch (role) {
      case 'komunitas':
        return 'Komunitas';
      case 'admin':
        return 'Admin';
      case 'donatur':
      default:
        return 'Donatur';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'donatur',
      avatarUrl: json['avatar_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      carePoints: (json['care_points'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'address': address,
      'care_points': carePoints,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? avatarUrl,
    String? phoneNumber,
    String? address,
    int? carePoints,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      carePoints: carePoints ?? this.carePoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
