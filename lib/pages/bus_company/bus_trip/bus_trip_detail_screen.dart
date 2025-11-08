import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/widgets/bus_trip_widget/trip_info_card.dart';
import 'package:bus_ticket_app/widgets/bus_trip_widget/trip_time_card.dart';
import 'package:bus_ticket_app/widgets/bus_trip_widget/seat_layout_widget.dart';
import 'package:bus_ticket_app/widgets/bus_trip_widget/trip_revenue_card.dart';

class BusTripDetailScreen extends StatefulWidget {
  final MTrip trip;

  const BusTripDetailScreen({super.key, required this.trip});

  @override
  State<BusTripDetailScreen> createState() => _BusTripDetailScreenState();
}

class _BusTripDetailScreenState extends State<BusTripDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết chuyến #${widget.trip.id}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.orange[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed:
                () => {
                  context.push(
                    '/home-bus-company/bus-trip-edit',
                    extra: widget.trip,
                  ),
                },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripInfoCard(trip: widget.trip),
          const SizedBox(height: 16),
          TripTimeCard(trip: widget.trip),
          const SizedBox(height: 16),
          TripRevenueCard(trip: widget.trip),
          const SizedBox(height: 16),
          _buildBookedUsersButton(),
          const SizedBox(height: 16),
          _buildSeatMapSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSeatMapSection() {
    if (widget.trip.seatLayout == null) {
      return _buildEmptySeatLayout();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sơ đồ ghế',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00424B),
              ),
            ),
            const SizedBox(height: 20),
            SeatLayoutWidget(seatLayout: widget.trip.seatLayout!),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySeatLayout() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_seat, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có sơ đồ ghế',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookedUsersButton() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.push(
            '/home-bus-company/bus-trip-detail/bus-trip-booked-users',
            extra: widget.trip,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people, color: Colors.orange[800], size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh sách khách hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00424B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
