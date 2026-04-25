/// Represents a plant reminder for tracking watering and care schedules
class ReminderModel {
  final String id;
  final String userId;
  final String plantName;
  final DateTime datePlanted;
  final int numberOfPlants;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextReminderDate;
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.plantName,
    required this.datePlanted,
    required this.numberOfPlants,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.nextReminderDate,
    this.isActive = true,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'plantName': plantName,
      'datePlanted': datePlanted.toIso8601String(),
      'numberOfPlants': numberOfPlants,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'nextReminderDate': nextReminderDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create from Firestore document
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      plantName: map['plantName'] ?? '',
      datePlanted: map['datePlanted'] != null
          ? DateTime.parse(map['datePlanted'])
          : DateTime.now(),
      numberOfPlants: map['numberOfPlants'] ?? 1,
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      nextReminderDate: map['nextReminderDate'] != null
          ? DateTime.parse(map['nextReminderDate'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  /// Create a copy with updated fields
  ReminderModel copyWith({
    String? id,
    String? userId,
    String? plantName,
    DateTime? datePlanted,
    int? numberOfPlants,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextReminderDate,
    bool? isActive,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plantName: plantName ?? this.plantName,
      datePlanted: datePlanted ?? this.datePlanted,
      numberOfPlants: numberOfPlants ?? this.numberOfPlants,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextReminderDate: nextReminderDate ?? this.nextReminderDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'ReminderModel(id: $id, plantName: $plantName, numberOfPlants: $numberOfPlants)';
}
