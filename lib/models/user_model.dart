import 'dart:convert';

class MUser {
  final int id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? role;
  final DateTime? createdAt;
  final String? avatarUrl;
  MUser({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.role,
    this.createdAt,
    this.avatarUrl,
  });

  MUser copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return MUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'avatarUrl': avatarUrl,
    };
  }

  factory MUser.fromMap(Map<String, dynamic> map) {
    return MUser(
      id: map['id'] as int,
      email: map['email'] != null ? map['email'] as String : null,
      fullName: map['full_name'] != null ? map['full_name'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      role: map['role'] != null ? map['role'] as String : null,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null,
      avatarUrl: map['avatar_url'] != null ? map['avatar_url'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MUser.fromJson(String source) =>
      MUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, phone: $phone, role: $role, createdAt: $createdAt, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(covariant MUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phone == phone &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        phone.hashCode ^
        role.hashCode ^
        createdAt.hashCode ^
        avatarUrl.hashCode;
  }
}
