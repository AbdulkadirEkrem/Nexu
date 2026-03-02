class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final int? avatarId;
  final String department;
  final String position;
  final String? companyDomain;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.avatarId,
    required this.department,
    required this.position,
    this.companyDomain,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatarId: json['avatarId'] as int?,
      department: json['department'] as String,
      position: json['position'] as String,
      companyDomain: json['companyDomain'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'avatarId': avatarId,
      'department': department,
      'position': position,
      'companyDomain': companyDomain,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    int? avatarId,
    String? department,
    String? position,
    String? companyDomain,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarId: avatarId ?? this.avatarId,
      department: department ?? this.department,
      position: position ?? this.position,
      companyDomain: companyDomain ?? this.companyDomain,
    );
  }
}

