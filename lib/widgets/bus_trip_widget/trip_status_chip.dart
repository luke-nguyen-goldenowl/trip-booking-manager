import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/trip_model.dart';

class _StatusConfig {
  final Color color;
  final String text;
  final IconData icon;

  _StatusConfig({required this.color, required this.text, required this.icon});
}

class TripStatusChip extends StatelessWidget {
  final BusTripStatus status;
  final double fontSize;

  const TripStatusChip({super.key, required this.status, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusConfig.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig.icon,
            size: fontSize + 2,
            color: statusConfig.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusConfig.text,
            style: TextStyle(
              color: statusConfig.color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(BusTripStatus status) {
    switch (status) {
      case BusTripStatus.scheduled:
        return _StatusConfig(
          color: Colors.blue,
          text: 'Đã lên lịch',
          icon: Icons.schedule,
        );
      case BusTripStatus.completed:
        return _StatusConfig(
          color: Colors.green,
          text: 'Hoàn thành',
          icon: Icons.check_circle,
        );
    }
  }
}
