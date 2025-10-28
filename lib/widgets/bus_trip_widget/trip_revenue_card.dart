import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';

class TripRevenueCard extends StatelessWidget {
  final MTrip trip;

  const TripRevenueCard({super.key, required this.trip});

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

            _buildRevenueStats(trip),
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
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.monetization_on,
            color: Colors.amber,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Thống kê doanh thu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00424B),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueStats(MTrip trip) {
    final bookedSeatsCount = _calculateBookedSeats();
    final basePrice = trip.price ?? 0;
    final totalRevenue = bookedSeatsCount * basePrice;

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            'Số vé đã đặt',
            '$bookedSeatsCount vé',
            Icons.confirmation_number,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatBox(
            'Doanh thu',
            "${FormatHelper.formatCurrency(totalRevenue.toDouble())} VNĐ",
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateBookedSeats() {
    if (trip.seatLayout == null) return 0;

    final seats = trip.seatLayout!['seats'] as List?;
    if (seats == null || seats.isEmpty) return 0;

    int bookedCount = 0;
    for (var seat in seats) {
      final isBooked = seat['isBooked'] as bool? ?? false;
      if (isBooked) {
        bookedCount++;
      }
    }

    return bookedCount;
  }
}
