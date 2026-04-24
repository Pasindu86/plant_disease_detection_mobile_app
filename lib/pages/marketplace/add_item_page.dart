import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/market_item.dart';
import '../../services/marketplace_service.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController(); // Phone number controller
  
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final MarketplaceService _marketplaceService = MarketplaceService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    // Added imageQuality and maxWidth to significantly reduce image size
    // so it uploads fast even on a slow emulator network connection!
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, 
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Safety check - make sure user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add an item.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      String imageUrl = '';
      
      if (_image != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Step 1: Uploading image...')));
        
        // Increased timeout to 60 seconds
        imageUrl = await _marketplaceService.uploadImage(_image!).timeout(const Duration(seconds: 30), onTimeout: () {
          throw Exception("Image upload timed out after 30 seconds");
        });
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Step 2: Saving details...')));

      final String sellerId = user.uid;
      final String sellerName = user.email ?? 'Anonymous User';

      final newItem = MarketItem(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
        sellerId: sellerId,
        sellerName: sellerName,
        phoneNumber: _phoneController.text, // Include phone number
      );

      print('Calling marketplaceService.addItem...');
      await _marketplaceService.addItem(newItem).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception("Connecting to Firestore timed out after 30 seconds. Check Database Rules or Internet!");
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Market Item'), backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Item Name / Title'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (LKR)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a price' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Post Item'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}