import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Expanded(child: Divider(color: Color(0xFFE0E0E0))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Color(0xFFE0E0E0))),
        ],
      ),
    );
  }
}
