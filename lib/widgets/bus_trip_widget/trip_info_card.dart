import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'trip_status_chip.dart';

class TripInfoCard extends StatelessWidget {
  final MTrip trip;
  final bool showHeader;

  const TripInfoCard({super.key, required this.trip, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[_buildHeader(), const Divider(height: 32)],
            _buildRouteInfo(context),
            const SizedBox(height: 12),
            _buildBusInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_bus, color: Colors.blue, size: 40),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chuyến #${trip.id}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00424B),
                ),
              ),
              TripStatusChip(status: trip.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    return BlocBuilder<BusRouteCubit, BusRouteState>(
      builder: (context, routeState) {
        String routeDisplay = '';

        if (routeState is BusRouteLoaded) {
          final route = routeState.routes.firstWhere(
            (r) => r.id == trip.routeId,
            orElse: () => MRoute(status: BusRouteStatus.active),
          );

          if (route.id != null &&
              route.departure != null &&
              route.destination != null) {
            routeDisplay = '${route.departure} → ${route.destination}';
          }
        }

        return _buildInfoRow(Icons.route, 'Tuyến đường', routeDisplay);
      },
    );
  }

  Widget _buildBusInfo(BuildContext context) {
    return BlocBuilder<BusCubit, BusState>(
      builder: (context, busState) {
        String busDisplay = '';

        if (busState is BusLoaded) {
          final bus = busState.buses.firstWhere(
            (b) => b.id == trip.busId,
            orElse: () => MBus(type: BusType.seater, status: BusStatus.active),
          );

          if (bus.id != null && bus.busNumber != null) {
            busDisplay = bus.busNumber!;
          }
        }

        return _buildInfoRow(Icons.directions_bus, 'Xe', busDisplay);
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
