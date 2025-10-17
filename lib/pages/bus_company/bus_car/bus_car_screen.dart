import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/widgets/bus_card.dart';
import 'package:bus_ticket_app/models/MBus.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';

class BusCarScreen extends StatefulWidget {
  const BusCarScreen({super.key});

  @override
  State<BusCarScreen> createState() => _BusCarScreenState();
}

class _BusCarScreenState extends State<BusCarScreen> {
  final TextEditingController _searchController = TextEditingController();
  BusType? _selectedBusType;
  BusStatus? _selectedBusStatus;
  bool _isFilterExpanded = false;
  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  void _loadBuses() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      final companyId = userState.user.id;
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
      body: BlocConsumer<BusCubit, BusState>(
        listener: (context, state) {
          if (state is BusError) {
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
          if (state is BusDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Xóa xe thành công!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm biển số xe...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
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
                Expanded(child: _buildBusListContent(state)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/home-bus-company/bus-car-add');
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildFilterSection() {
    final hasActiveFilter =
        _selectedBusType != null || _selectedBusStatus != null;

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
                        color: hasActiveFilter ? Colors.orange : Colors.black87,
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
                      child: Text(
                        '${(_selectedBusType != null ? 1 : 0) + (_selectedBusStatus != null ? 1 : 0)}',
                        style: const TextStyle(
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
                        'Loại xe',
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
                            isSelected: _selectedBusType == null,
                            onSelected: () {
                              setState(() {
                                _selectedBusType = null;
                              });
                            },
                          ),
                          ...BusType.values.map((type) {
                            return _buildFilterChip(
                              label: _getBusTypeName(type),
                              icon: _getBusTypeIcon(type),
                              isSelected: _selectedBusType == type,
                              onSelected: () {
                                setState(() {
                                  _selectedBusType = type;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

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
                            isSelected: _selectedBusStatus == null,
                            onSelected: () {
                              setState(() {
                                _selectedBusStatus = null;
                              });
                            },
                          ),
                          ...BusStatus.values.map((status) {
                            return _buildFilterChip(
                              label: _getStatusName(status),
                              color: _getStatusColor(status),
                              isSelected: _selectedBusStatus == status,
                              onSelected: () {
                                setState(() {
                                  _selectedBusStatus = status;
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
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : (color ?? Colors.orange),
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
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

  Widget _buildBusListContent(BusState state) {
    if (state is BusLoading) {
      return buildSkeletonLoading();
    }
    if (state is BusLoaded || state is BusDeleted) {
      final buses =
          state is BusLoaded ? state.buses : (state as BusDeleted).buses;

      final filteredBuses =
          buses.where((bus) {
            final searchQuery = _searchController.text.toLowerCase();
            final matchesSearch =
                searchQuery.isEmpty ||
                (bus.busNumber?.toLowerCase().contains(searchQuery) ?? false);

            final matchesBusType =
                _selectedBusType == null || bus.type == _selectedBusType;

            final matchesStatus =
                _selectedBusStatus == null || bus.status == _selectedBusStatus;

            return matchesSearch && matchesBusType && matchesStatus;
          }).toList();

      if (filteredBuses.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_bus_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không tìm thấy xe phù hợp',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _loadBuses();
        },
        child: ListView.builder(
          itemCount: filteredBuses.length,
          itemBuilder: (context, index) {
            final bus = filteredBuses[index];
            return BusCard(
              bus: bus,
              onView: () {
                context.go('/home-bus-company/bus-car-detail', extra: bus);
              },
              onEdit: () {
                context.go('/home-bus-company/bus-car-edit', extra: bus);
              },
              onDelete: () async {
                final confirmed = await DialogHelper.showDeleteConfirmation(
                  context,
                  itemName: 'xe ${bus.busNumber}',
                  itemType: 'xe',
                );
                if (confirmed && mounted) {
                  final userState = context.read<UserCubit>().state;
                  if (userState is UserLoaded && bus.id != null) {
                    context.read<BusCubit>().deleteBus(
                      bus.id!,
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có dữ liệu',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getBusTypeIcon(BusType type) {
    switch (type) {
      case BusType.limousine:
        return Icons.airline_seat_flat;
      case BusType.sleeper:
        return Icons.hotel;
      case BusType.seater:
        return Icons.event_seat;
    }
  }

  String _getBusTypeName(BusType type) {
    switch (type) {
      case BusType.limousine:
        return 'Limousine';
      case BusType.sleeper:
        return 'Giường nằm';
      case BusType.seater:
        return 'Ghế ngồi';
    }
  }

  Color _getStatusColor(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return Colors.green;
      case BusStatus.maintenance:
        return Colors.orange;
      case BusStatus.inactive:
        return Colors.red;
    }
  }

  String _getStatusName(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return 'Hoạt động';
      case BusStatus.maintenance:
        return 'Bảo trì';
      case BusStatus.inactive:
        return 'Ngưng';
    }
  }
}
