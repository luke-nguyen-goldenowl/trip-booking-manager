import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:intl/intl.dart';

class TripTimeCard extends StatelessWidget {
  final MTrip trip;

  const TripTimeCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTimeBox(
                    'Khởi hành',
                    trip.departureTime,
                    Icons.flight_takeoff,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeBox(
                    'Đến',
                    trip.arrivalTime,
                    Icons.flight_land,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (trip.departureTime != null && trip.arrivalTime != null) ...[
              const SizedBox(height: 16),
              _buildDurationBadge(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.access_time, color: Colors.green, size: 24),
        ),
        const SizedBox(width: 12),
        const Text(
          'Thời gian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00424B),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(
    String label,
    DateTime? dateTime,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateTime != null
                ? DateFormat('dd/MM/yyyy').format(dateTime)
                : 'N/A',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            dateTime != null ? DateFormat('HH:mm').format(dateTime) : '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationBadge() {
    final duration = _calculateDuration();

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.purple, size: 20),
          const SizedBox(width: 8),
          Text(
            'Thời gian di chuyển: $duration',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
    if (trip.departureTime == null || trip.arrivalTime == null) {
      return 'N/A';
    }

    final duration = trip.arrivalTime!.difference(trip.departureTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours == 0) {
      return '$minutes phút';
    } else if (minutes == 0) {
      return '$hours giờ';
    } else {
      return '$hours giờ $minutes phút';
    }
  }
}
