import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';

class PopularTripCard extends StatelessWidget {
  final MTrip trip;
  const PopularTripCard({super.key, required this.trip});

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

  @override
  Widget build(BuildContext context) {
    final duration =
        trip.departureTime != null && trip.arrivalTime != null
            ? '${trip.arrivalTime!.difference(trip.departureTime!).inHours}h ${trip.arrivalTime!.difference(trip.departureTime!).inMinutes.remainder(60)} m'
            : 'N/A';
    return BlocBuilder<BusRouteCubit, BusRouteState>(
      builder: (context, routeState) {
        return BlocBuilder<BusCubit, BusState>(
          builder: (context, busState) {
            final routes =
                routeState is BusRouteLoaded ? routeState.routes : <MRoute>[];
            final route = _getRoute(routes, trip.routeId ?? 0);
            return GestureDetector(
              onTap: () => {},
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/background_card.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.directions_bus,
                            size: 50,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  route.departure ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward, size: 16),
                              ),
                              Expanded(
                                child: Text(
                                  route.destination ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                FormatHelper.formatCurrency(
                                  (trip.price ?? 0).toDouble(),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    duration,
                                    style: TextStyle(
                                      fontSize: 14,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
