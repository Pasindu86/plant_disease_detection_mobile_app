import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_disease_detection_mobile_app/models/reminder_model.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _remindersCollection = 'reminders';
  static const int _reminderIntervalDays = 7; // Default watering interval

  /// Create a new reminder
  Future<ReminderModel> createReminder({
    required String plantName,
    required DateTime datePlanted,
    required int numberOfPlants,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now();
    final reminderId = _firestore.collection(_remindersCollection).doc().id;

    // Calculate next reminder date (7 days from now by default)
    final nextReminderDate = now.add(
      const Duration(days: _reminderIntervalDays),
    );

    final reminder = ReminderModel(
      id: reminderId,
      userId: user.uid,
      plantName: plantName,
      datePlanted: datePlanted,
      numberOfPlants: numberOfPlants,
      description: description,
      createdAt: now,
      updatedAt: now,
      nextReminderDate: nextReminderDate,
      isActive: true,
    );

    await _firestore
        .collection(_remindersCollection)
        .doc(reminderId)
        .set(reminder.toMap());

    return reminder;
  }

  /// Get all reminders for current user
  Stream<List<ReminderModel>> getUserReminders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_remindersCollection)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final reminders = snapshot.docs
              .map((doc) => ReminderModel.fromMap(doc.data()))
              .toList();
          // Sort locally by datePlanted (newest first)
          reminders.sort((a, b) => b.datePlanted.compareTo(a.datePlanted));
          return reminders;
        });
  }

  /// Get a specific reminder
  Future<ReminderModel?> getReminder(String reminderId) async {
    final doc = await _firestore
        .collection(_remindersCollection)
        .doc(reminderId)
        .get();

    if (doc.exists) {
      return ReminderModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Update a reminder
  Future<void> updateReminder(ReminderModel reminder) async {
    final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection(_remindersCollection)
        .doc(reminder.id)
        .update(updatedReminder.toMap());
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection(_remindersCollection).doc(reminderId).delete();
  }

  /// Mark reminder as inactive (instead of deleting)
  Future<void> markReminderInactive(String reminderId) async {
    final reminder = await getReminder(reminderId);
    if (reminder != null) {
      await updateReminder(reminder.copyWith(isActive: false));
    }
  }

  /// Update next reminder date for a reminder
  Future<void> updateNextReminderDate(
    String reminderId,
    DateTime nextDate,
  ) async {
    final reminder = await getReminder(reminderId);
    if (reminder != null) {
      await updateReminder(reminder.copyWith(nextReminderDate: nextDate));
    }
  }

  /// Get reminders that are due (nextReminderDate is today or earlier)
  Stream<List<ReminderModel>> getDueReminders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_remindersCollection)
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) => ReminderModel.fromMap(doc.data()))
              .where((reminder) {
                if (reminder.nextReminderDate == null) return false;
                return reminder.nextReminderDate!.isBefore(now) ||
                    reminder.nextReminderDate!.difference(now).inDays == 0;
              })
              .toList();
        });
  }
}
