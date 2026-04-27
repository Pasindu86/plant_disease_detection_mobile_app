class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? profilePhoto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.profilePhoto,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePhoto': profilePhoto,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profilePhoto: map['profilePhoto'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? address,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
