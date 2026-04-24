import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_item.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadImage(File image) async {
    try {
      print('Converting image to Base64 to bypass Storage...');
      
      // Read the file as raw bytes
      Uint8List bytes = await image.readAsBytes();
      
      // Encode those raw bytes into a Base64 String
      String base64Image = base64Encode(bytes);
      
      return base64Image;
    } catch (e) {
      print('Failed to convert image to Base64: $e');
      rethrow;
    }
  }

  Future<void> addItem(MarketItem item) async {
    try {
      print('Creating Firestore document...');
      DocumentReference docRef = _firestore.collection('marketplace').doc();
      MarketItem itemWithId = item.copyWith(id: docRef.id);
      print('Setting Firestore data for ${docRef.id}...');
      await docRef.set(itemWithId.toMap());
      print('Firestore data set successfully!');
    } catch (e) {
      print('Error in addItem: $e');
      rethrow;
    }
  }

  Stream<List<MarketItem>> getItems() {
    return _firestore.collection('marketplace').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MarketItem.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection('marketplace').doc(itemId).delete();
      print('Item $itemId deleted successfully.');
    } catch (e) {
      print('Failed to delete item: $e');
      rethrow;
    }
  }
}