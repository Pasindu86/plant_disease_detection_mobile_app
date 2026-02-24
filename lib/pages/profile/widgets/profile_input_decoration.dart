import 'package:flutter/material.dart';

/// Creates an [InputDecoration] for profile form fields.
InputDecoration profileInputDecoration({
  required String hint,
  required IconData icon,
  required bool isEditing,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
    filled: true,
    fillColor: isEditing ? Colors.white : Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isEditing ? Colors.grey.shade300 : Colors.transparent,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
