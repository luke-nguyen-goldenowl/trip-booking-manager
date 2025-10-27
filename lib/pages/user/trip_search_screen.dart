import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_cubit.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_state.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/widgets/trip_card_search.dart';
import 'package:bus_ticket_app/utils/helper/seat_layout_helper.dart';

class TripSearchScreen extends StatefulWidget {
  const TripSearchScreen({super.key, required this.searchParams});

  final Map<String, dynamic> searchParams;

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  List<MTrip> _filteredTrips = [];
  List<MTrip> trips = [];
  List<String> choiceChipValue = [
    'Giá giảm dần',
    'Giá tăng dần',
    'Giờ đi',
    'Thời gian di chuyển',
  ];
  String? _selectedChip;

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
  void initState() {
    super.initState();
    _loadTrip();
  }

  void _loadTrip() {
    context.read<BusTripCubit>().loadAllTrips();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Kết quả tìm kiếm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF004049),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFF004049),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Điểm đi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.searchParams['departure'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF004049),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Điểm đến',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.searchParams['destination'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FormatHelper.formatDate(widget.searchParams['date']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.searchParams['passengers']} hành khách',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [_buildChoiceChips()],
              ),
            ),
            Expanded(
              child: BlocBuilder<BusTripCubit, BusTripState>(
                builder: (context, tripState) {
                  return BlocBuilder<BusRouteCubit, BusRouteState>(
                    builder: (context, routeState) {
                      if (tripState is BusTripLoading) {
                        return buildSkeletonLoading();
                      }
                      if (tripState is BusTripLoaded) {
                        trips = tripState.trips;
                        final routes =
                            routeState is BusRouteLoaded
                                ? routeState.routes
                                : <MRoute>[];
                        _filteredTrips =
                            trips.where((trip) {
                              final route = _getRoute(
                                routes,
                                trip.routeId ?? 0,
                              );
                              final matchesDeparture =
                                  route.departure ==
                                  (widget.searchParams['departure'] as String);
                              final matchesDestination =
                                  route.destination ==
                                  (widget.searchParams['destination']
                                      as String);
                              final matchesDate =
                                  FormatHelper.formatDate(trip.departureTime) ==
                                  FormatHelper.formatDate(
                                    widget.searchParams['date'],
                                  );
                              final isAvailableSeats =
                                  widget.searchParams['passengers'] <=
                                  SeatLayoutHelper.countAvailableSeats(
                                    trip.seatLayout,
                                  );
                              if (!isAvailableSeats) {
                                return false;
                              }
                              return matchesDeparture &&
                                  matchesDestination &&
                                  matchesDate;
                            }).toList();
                        _sortTrips();
                      }
                      if (_filteredTrips.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Không tìm thấy chuyến đi phù hợp.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = _filteredTrips[index];
                          return TripCardSearch(trip: trip);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
            choiceChipValue.map((value) {
              final isSelected = _selectedChip == value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(value),
                  selected: isSelected,
                  selectedColor: Colors.orange[300],
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedChip = selected ? value : null;
                      _sortTrips();
                    });
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  void _sortTrips() {
    switch (_selectedChip) {
      case 'Giờ đi':
        _filteredTrips.sort(
          (a, b) => a.departureTime!.compareTo(b.departureTime!),
        );
        break;
      case 'Giá tăng dần':
        _filteredTrips.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'Giá giảm dần':
        _filteredTrips.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'Thời gian':
        _filteredTrips.sort((a, b) {
          final durationA = a.arrivalTime!.difference(a.departureTime!);
          final durationB = b.arrivalTime!.difference(b.departureTime!);
          return durationA.compareTo(durationB);
        });
        break;
    }
  }
}
