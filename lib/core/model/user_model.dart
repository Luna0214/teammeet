import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String profileImage;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.profileImage,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }
}
