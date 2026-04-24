import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/market_item.dart';

class ItemDetailPage extends StatelessWidget {
  final MarketItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    Widget itemImage = const Icon(Icons.image, size: 100, color: Colors.grey);
    if (item.imageUrl.isNotEmpty) {
      try {
        itemImage = Image.memory(
          base64Decode(item.imageUrl),
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        );
      } catch (e) {
        itemImage = const Icon(Icons.broken_image, size: 100, color: Colors.grey);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemImage,
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LKR ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, color: Color(0xFF4CAF50), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description.isNotEmpty ? item.description : 'No description provided.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(height: 30, thickness: 1),
                  const Text(
                    'Seller Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: Color(0xFF4CAF50)),
                    title: Text(item.sellerName),
                    subtitle: const Text('Seller Name'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                    title: Text(item.phoneNumber.isNotEmpty ? item.phoneNumber : 'Not provided'),
                    subtitle: const Text('Contact Number'),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${item.phoneNumber}...')),
                        );
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Call Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
