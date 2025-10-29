import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'package:intl/intl.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';
import 'package:bus_ticket_app/utils/helper/seat_layout_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:go_router/go_router.dart';

class TripCardSearch extends StatelessWidget {
  const TripCardSearch({super.key, required this.trip});

  final MTrip trip;

  MRoute _getRoute(List<MRoute> routes, int routeId) {
    try {
      return routes.firstWhere(
        (route) => route.id == routeId,
        orElse: () => MRoute(status: BusRouteStatus.active),
      );
    } catch (e) {
      return MRoute(status: BusRouteStatus.active);
    }
  }

  MBus _getBus(List<MBus> buses, int busId) {
    try {
      return buses.firstWhere(
        (bus) => bus.id == busId,
        orElse: () => MBus(type: BusType.seater, status: BusStatus.active),
      );
    } catch (e) {
      return MBus(type: BusType.seater, status: BusStatus.active);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusRouteCubit, BusRouteState>(
      builder: (context, routeState) {
        return BlocBuilder<BusCubit, BusState>(
          builder: (context, busState) {
            final routes =
                routeState is BusRouteLoaded ? routeState.routes : <MRoute>[];
            final buses = busState is BusLoaded ? busState.buses : <MBus>[];
            final route = _getRoute(routes, trip.routeId ?? 0);
            final bus = _getBus(buses, trip.busId ?? 0);
            final duration = trip.arrivalTime!.difference(trip.departureTime!);
            final hours = duration.inHours;
            final minutes = duration.inMinutes.remainder(60);
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.push(
                      '/user/trip-detail',
                      extra: {'trip': trip, 'route': route, 'bus': bus},
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(trip.departureTime!),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00424B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    route.departure ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${hours}h ${minutes}m',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(trip.arrivalTime!),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00424B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    route.destination ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(trip.departureTime!),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.directions_bus,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus.busNumber ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${BusHelper.getBusTypeName(bus.type)} • ${bus.seatCount} ghế',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Còn ${SeatLayoutHelper.countAvailableSeats(trip.seatLayout)} ghế trống',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          SeatLayoutHelper.countAvailableSeats(
                                                    trip.seatLayout,
                                                  ) >
                                                  5
                                              ? Colors.green
                                              : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  FormatHelper.formatCurrency(
                                    trip.price!.toDouble(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '/người',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
