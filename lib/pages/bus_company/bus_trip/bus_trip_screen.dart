import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_cubit.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_state.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:bus_ticket_app/widgets/bus_trip_widget/bus_trip_card.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';
import 'package:diacritic/diacritic.dart';

class BusTripScreen extends StatefulWidget {
  const BusTripScreen({super.key});

  @override
  State<BusTripScreen> createState() => _BusTripScreenState();
}

class _BusTripScreenState extends State<BusTripScreen> {
  final TextEditingController _searchController = TextEditingController();
  BusTripStatus? _selectedStatus;
  bool _isFilterExpanded = false;
  List<MRoute> _routes = [];
  List<MBus> _buses = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadRoutesAndBuses();
  }

  void _loadTrips() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      final companyId = userState.user.id;
      context.read<BusTripCubit>().loadTrips(companyId);
    }
  }

  void _loadRoutesAndBuses() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      final companyId = userState.user.id;
      context.read<BusRouteCubit>().loadRoutes(companyId);
      context.read<BusCubit>().loadBuses(companyId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<BusRouteCubit, BusRouteState>(
            listener: (context, state) {
              if (state is BusRouteLoaded) {
                setState(() {
                  _routes = state.routes;
                });
              }
            },
          ),
          BlocListener<BusCubit, BusState>(
            listener: (context, state) {
              if (state is BusLoaded) {
                setState(() {
                  _buses = state.buses;
                });
              }
            },
          ),
        ],
        child: BlocConsumer<BusTripCubit, BusTripState>(
          listener: (context, state) {
            if (state is BusTripError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is BusTripDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Xóa chuyến đi thành công'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                _loadTrips();
                _loadRoutesAndBuses();
              },
              child: Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(child: _buildTripList(state)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/home-bus-company/bus-trip-add');
        },
        backgroundColor: Colors.orange,
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm chuyến đi...',
              hintStyle: const TextStyle(color: Colors.black),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 10),

          _buildFilterSection(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    Color? color,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: color ?? Colors.orange,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? (color ?? Colors.orange) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final hasActiveFilter = _selectedStatus != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: hasActiveFilter ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasActiveFilter ? 'Đang lọc' : 'Bộ lọc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: hasActiveFilter ? Colors.orange : Colors.black,
                      ),
                    ),
                  ),
                  if (hasActiveFilter)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isFilterExpanded)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00424B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildFilterChip(
                            label: 'Tất cả',
                            isSelected: _selectedStatus == null,
                            onSelected: () {
                              setState(() {
                                _selectedStatus = null;
                              });
                            },
                          ),
                          ...BusTripStatus.values.map((status) {
                            return _buildFilterChip(
                              label: BusHelper.getTripStatusName(status),
                              color: BusHelper.getTripStatusColor(status),
                              isSelected: _selectedStatus == status,
                              onSelected: () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTripList(BusTripState state) {
    if (state is BusTripLoading) {
      return buildSkeletonLoading();
    }

    if (state is BusTripLoaded) {
      var trips = state.trips;
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        trips =
            trips.where((trip) {
              if (trip.id.toString().contains(searchLower)) return true;
              final route = _routes.firstWhere(
                (r) => r.id == trip.routeId,
                orElse: () => MRoute(status: BusRouteStatus.active),
              );

              if (route.id != null) {
                final routeName =
                    '${route.departure} ${route.destination}'.toLowerCase();
                final normalizedRouteName = removeDiacritics(routeName);
                final normalizedQuery = removeDiacritics(searchLower);
                if (normalizedRouteName.contains(normalizedQuery)) return true;
              }

              final bus = _buses.firstWhere(
                (b) => b.id == trip.busId,
                orElse:
                    () => MBus(type: BusType.seater, status: BusStatus.active),
              );
              if (bus.id != null && bus.busNumber != null) {
                if (bus.busNumber!.toLowerCase().contains(searchLower)) {
                  return true;
                }
              }

              return false;
            }).toList();
      }

      if (_selectedStatus != null) {
        trips = trips.where((trip) => trip.status == _selectedStatus).toList();
      }

      if (trips.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có chuyến đi nào',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTripCard(MTrip trip) {
    final route = _routes.firstWhere(
      (r) => r.id == trip.routeId,
      orElse: () => MRoute(status: BusRouteStatus.active),
    );
    final bus = _buses.firstWhere(
      (b) => b.id == trip.busId,
      orElse: () => MBus(type: BusType.seater, status: BusStatus.active),
    );

    return BusTripCard(
      trip: trip,
      route: route,
      bus: bus,
      onEdit: () {
        context.push('/home-bus-company/bus-trip-edit', extra: trip);
      },
      onDelete: () async {
        final confirmed = await DialogHelper.showDeleteConfirmation(
          context,
          itemName: 'chuyến #${trip.id}',
          itemType: 'chuyến đi',
        );
        if (confirmed && mounted) {
          final userState = context.read<UserCubit>().state;
          if (userState is UserLoaded && trip.id != null) {
            context.read<BusTripCubit>().deleteTrip(
              trip.id!,
              userState.user.id,
            );
          }
        }
      },
    );
  }
}
