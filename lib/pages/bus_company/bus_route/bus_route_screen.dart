import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/widgets/bus_route_card.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';
import 'package:diacritic/diacritic.dart';

class BusRouteScreen extends StatefulWidget {
  const BusRouteScreen({super.key});

  @override
  State<BusRouteScreen> createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
  final TextEditingController _searchController = TextEditingController();
  BusRouteStatus? _selectedStatus;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  void _loadRoutes() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      final companyId = userState.user.id;
      context.read<BusRouteCubit>().loadRoutes(companyId);
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
      body: BlocConsumer<BusRouteCubit, BusRouteState>(
        listener: _handleRouteStateChanges,
        builder: (context, routeState) => _buildBody(routeState),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          context.push('/home-bus-company/bus-route-add');
        },
        backgroundColor: Colors.orange[300],
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildBody(BusRouteState routeState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm điểm đi, điểm đến...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
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
              fillColor: Colors.grey[600],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 10),

          _buildFilterSection(),

          const SizedBox(height: 10),

          Expanded(child: _buildRouteListContent(routeState)),
        ],
      ),
    );
  }

  void _handleRouteStateChanges(BuildContext context, BusRouteState state) {
    if (state is BusRouteError) {
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
    if (state is BusRouteDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Xóa tuyến đường thành công!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                          ...BusRouteStatus.values.map((status) {
                            return _buildFilterChip(
                              label: BusHelper.getRouteStatusName(status),
                              color: BusHelper.getRouteStatusColor(status),
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

  Widget _buildRouteListContent(BusRouteState state) {
    if (state is BusRouteLoading) {
      return buildSkeletonLoading();
    }

    if (state is BusRouteLoaded || state is BusRouteDeleted) {
      final routes =
          state is BusRouteLoaded
              ? state.routes
              : (state as BusRouteDeleted).routes;

      final filteredRoutes =
          routes.where((route) {
            final searchQuery = _searchController.text.toLowerCase();
            final normalizedQuery = removeDiacritics(searchQuery);

            final matchesSearch =
                searchQuery.isEmpty ||
                (route.departure != null &&
                    removeDiacritics(
                      route.departure!.toLowerCase(),
                    ).contains(normalizedQuery)) ||
                (route.destination != null &&
                    removeDiacritics(
                      route.destination!.toLowerCase(),
                    ).contains(normalizedQuery));

            final matchesStatus =
                _selectedStatus == null || route.status == _selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();

      if (filteredRoutes.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.route_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Không tìm thấy tuyến đường phù hợp',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _loadRoutes();
        },
        child: ListView.builder(
          itemCount: filteredRoutes.length,
          itemBuilder: (context, index) {
            final route = filteredRoutes[index];
            return BusRouteCard(
              route: route,
              onView: () {
                context.push(
                  '/home-bus-company/bus-route-detail',
                  extra: route,
                );
              },
              onEdit: () {
                context.push('/home-bus-company/bus-route-edit', extra: route);
              },
              onDelete: () async {
                final confirmed = await DialogHelper.showDeleteConfirmation(
                  context,
                  itemName: 'tuyến ${route.departure} → ${route.destination}',
                  itemType: 'tuyến đường',
                );
                if (confirmed && mounted) {
                  final userState = context.read<UserCubit>().state;
                  if (userState is UserLoaded && route.id != null) {
                    context.read<BusRouteCubit>().deleteRoute(
                      route.id!,
                      userState.user.id,
                    );
                  }
                }
              },
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
