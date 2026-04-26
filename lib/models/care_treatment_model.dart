import 'package:cloud_firestore/cloud_firestore.dart';

class CareTreatmentModel {
  final String id;
  final String userId;
  final String diseaseName;
  final String tips;
  final DateTime createdAt;

  CareTreatmentModel({
    required this.id,
    required this.userId,
    required this.diseaseName,
    required this.tips,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'diseaseName': diseaseName,
      'tips': tips,
      'createdAt': createdAt,
    };
  }

  factory CareTreatmentModel.fromMap(Map<String, dynamic> map) {
    return CareTreatmentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      tips: map['tips'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
