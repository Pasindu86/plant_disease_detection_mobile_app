import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plant_disease_detection_mobile_app/services/reminder_service.dart';
import 'package:plant_disease_detection_mobile_app/models/reminder_model.dart';
import 'package:plant_disease_detection_mobile_app/pages/garden/new_reminder_form.dart';
import 'package:plant_disease_detection_mobile_app/widgets/custom_bottom_navbar.dart';
import 'package:plant_disease_detection_mobile_app/widgets/header_action_buttons.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  final ReminderService _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Reminders',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: const [HeaderActionButtons(), SizedBox(width: 16)],
      ),
      body: _buildGardenContent(),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildGardenContent() {
    return StreamBuilder<List<ReminderModel>>(
      stream: _reminderService.getUserReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFE53935),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          );
        }

        final reminders = snapshot.data ?? [];
        final activeReminders = reminders.where((r) => r.isActive).toList();

        if (activeReminders.isEmpty) {
          return _buildEmptyState(context);
        }

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Reminders Count Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Reminders',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${activeReminders.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        FontAwesomeIcons.leaf,
                        size: 30,
                        color: const Color(0xFF4CAF50).withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reminders List
                ...activeReminders.map((reminder) {
                  return _buildReminderCard(context, reminder);
                }).toList(),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
            Positioned(bottom: 20, right: 16, child: _buildFAB(context)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.leaf,
            size: 60,
            color: const Color(0xFF4CAF50).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Reminders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first reminder to start tracking\nyour plants and receive care notifications',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => NewReminderForm(
                  onReminderCreated: (reminder) {
                    setState(() {});
                  },
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Reminder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => NewReminderForm(
            onReminderCreated: (reminder) {
              setState(() {});
            },
          ),
        );
      },
      backgroundColor: const Color(0xFF4CAF50),
      icon: const Icon(Icons.add),
      label: const Text('New Reminder'),
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder) {
    final now = DateTime.now();
    final daysPlanted = now.difference(reminder.datePlanted).inDays;
    final nextReminderDate = reminder.nextReminderDate;
    final daysUntilReminder = nextReminderDate?.difference(now).inDays ?? 0;

    bool isDue = daysUntilReminder <= 0 && nextReminderDate != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isDue ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isDue
              ? Border.all(color: const Color(0xFFFFA500), width: 2)
              : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Plant Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.plantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reminder.numberOfPlants} plant${reminder.numberOfPlants > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA500).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFA500)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: Color(0xFFFFA500),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Due Now',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFA500),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                reminder.description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Timeline Info
              Row(
                children: [
                  Expanded(
                    child: _buildTimelineTile(
                      icon: Icons.calendar_today,
                      label: 'Planted',
                      value: '$daysPlanted days ago',
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimelineTile(
                      icon: Icons.notifications_active,
                      label: 'Next Reminder',
                      value: daysUntilReminder < 0
                          ? 'Overdue'
                          : '$daysUntilReminder days',
                      color: isDue
                          ? const Color(0xFFFFA500)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _markReminderDone(reminder),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark Done'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deleteReminder(reminder),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markReminderDone(ReminderModel reminder) async {
    final nextDate = DateTime.now().add(const Duration(days: 7));
    await _reminderService.updateNextReminderDate(reminder.id, nextDate);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${reminder.plantName} reminder scheduled for ${nextDate.day}/${nextDate.month}/${nextDate.year}',
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  Future<void> _deleteReminder(ReminderModel reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text(
          'Are you sure you want to delete the reminder for ${reminder.plantName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _reminderService.deleteReminder(reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
      }
    }
  }
}
