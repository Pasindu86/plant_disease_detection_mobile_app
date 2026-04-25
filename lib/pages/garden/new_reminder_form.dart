import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/services/reminder_service.dart';
import 'package:plant_disease_detection_mobile_app/models/reminder_model.dart';

class NewReminderForm extends StatefulWidget {
  final Function(ReminderModel) onReminderCreated;

  const NewReminderForm({super.key, required this.onReminderCreated});

  @override
  State<NewReminderForm> createState() => _NewReminderFormState();
}

class _NewReminderFormState extends State<NewReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _numberOfPlantsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  final ReminderService _reminderService = ReminderService();

  @override
  void dispose() {
    _plantNameController.dispose();
    _numberOfPlantsController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      // Try parsing formats: dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd
      dateString = dateString.trim();
      List<int>? parts;

      if (dateString.contains('/')) {
        parts = dateString.split('/').map(int.parse).toList();
        if (parts.length == 3) {
          return DateTime(parts[2], parts[1], parts[0]);
        }
      } else if (dateString.contains('-')) {
        parts = dateString.split('-').map(int.parse).toList();
        if (parts.length == 3) {
          // Check if format is dd-mm-yyyy or yyyy-mm-dd
          if (parts[0] > 30) {
            // yyyy-mm-dd
            return DateTime(parts[0], parts[1], parts[2]);
          } else {
            // dd-mm-yyyy
            return DateTime(parts[2], parts[1], parts[0]);
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a planting date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reminder = await _reminderService.createReminder(
        plantName: _plantNameController.text.trim(),
        datePlanted: _selectedDate!,
        numberOfPlants: int.parse(_numberOfPlantsController.text),
        description: _descriptionController.text.trim(),
      );

      widget.onReminderCreated(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Reminder created successfully! Starting reminder process...',
            ),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Reminder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Plant Name Field
                TextFormField(
                  controller: _plantNameController,
                  decoration: InputDecoration(
                    labelText: 'Plant Name',
                    hintText: 'e.g., Chili, Tomato',
                    prefixIcon: const Icon(
                      Icons.local_florist,
                      color: Color(0xFF4CAF50),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter plant name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Planted Field
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date Planted',
                    hintText: 'dd/mm/yyyy or tap calendar',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF4CAF50),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF4CAF50),
                      ),
                      onPressed: () => _selectDate(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 3,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter or select a date';
                    }
                    final parsed = _parseDate(value);
                    if (parsed == null) {
                      return 'Invalid date format. Use dd/mm/yyyy';
                    }
                    if (parsed.isAfter(DateTime.now())) {
                      return 'Date cannot be in the future';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final parsed = _parseDate(value);
                      if (parsed != null) {
                        _selectedDate = parsed;
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Number of Plants Field
                TextFormField(
                  controller: _numberOfPlantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Plants',
                    prefixIcon: const Icon(
                      Icons.filter_none,
                      color: Color(0xFF4CAF50),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of plants';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Small Description',
                    hintText: 'e.g., Location, soil type, care notes...',
                    prefixIcon: const Icon(
                      Icons.description,
                      color: Color(0xFF4CAF50),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFFB0BEC5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save & Start Reminder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
