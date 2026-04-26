import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/care_treatment_model.dart';

class CareTreatmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'care_treatments';

  Future<CareTreatmentModel> saveTreatment({
    required String diseaseName,
    required String tips,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection(_collection).doc();
    final treatment = CareTreatmentModel(
      id: docRef.id,
      userId: user.uid,
      diseaseName: diseaseName,
      tips: tips,
      createdAt: DateTime.now(),
    );

    await docRef.set(treatment.toMap());
    return treatment;
  }

  Stream<List<CareTreatmentModel>> getUserTreatments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => CareTreatmentModel.fromMap(doc.data()))
              .toList();
          // Sort locally to avoid needing a Firestore composite index
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> deleteTreatment(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
