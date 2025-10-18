import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/MBus.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';

class BusCarEditScreen extends StatefulWidget {
  final MBus bus;

  const BusCarEditScreen({super.key, required this.bus});

  @override
  State<BusCarEditScreen> createState() => _BusCarEditScreenState();
}

class _BusCarEditScreenState extends State<BusCarEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _licensePlateController;

  late BusType _selectedBusType;
  late BusStatus _selectedStatus;
  late int _selectedSeatCount;

  final Map<BusType, List<int>> _seatCountByType = {
    BusType.sleeper: [40, 34, 24, 22],
    BusType.seater: [45, 29, 16],
    BusType.limousine: [16],
  };

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController(text: widget.bus.busNumber);
    _selectedBusType = widget.bus.type;
    _selectedStatus = widget.bus.status;
    _selectedSeatCount = widget.bus.seatCount ?? 16;
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    super.dispose();
  }

  List<int> _getAvailableSeatCounts() {
    return _seatCountByType[_selectedBusType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh Sửa Xe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            context.pop();
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: BlocConsumer<BusCubit, BusState>(
        listener: (context, busState) {
          if (busState is BusLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Cập nhật xe thành công!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          if (busState is BusError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(busState.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, busState) {
          return Stack(
            children: [
              BlocBuilder<UserCubit, UserState>(
                builder: (context, userState) {
                  if (userState is UserLoading) {
                    return buildSkeletonLoading();
                  }

                  if (userState is! UserLoaded) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 60, color: Colors.red),
                          SizedBox(height: 20),
                          Text(
                            'Không thể lấy thông tin người dùng',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  final user = userState.user;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        user.avatarUrl != null &&
                                                user.avatarUrl!.isNotEmpty
                                            ? NetworkImage(user.avatarUrl!)
                                            : const AssetImage(
                                                  'assets/images/user.png',
                                                )
                                                as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.fullName ?? 'Chưa cập nhật',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00424B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      user.role ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thông tin xe',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00424B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _licensePlateController,
                                    decoration: InputDecoration(
                                      labelText: 'Biển số xe *',
                                      prefixIcon: const Icon(
                                        Icons.confirmation_number,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập biển số xe';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<BusType>(
                                    value: _selectedBusType,
                                    decoration: InputDecoration(
                                      labelText: 'Loại xe *',
                                      prefixIcon: const Icon(
                                        Icons.directions_bus,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    items:
                                        BusType.values.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  BusHelper.getBusTypeIcon(
                                                    type,
                                                  ),
                                                  size: 20,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  BusHelper.getBusTypeName(
                                                    type,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedBusType = value;
                                          final availableSeats =
                                              _getAvailableSeatCounts();
                                          if (availableSeats.isNotEmpty &&
                                              !availableSeats.contains(
                                                _selectedSeatCount,
                                              )) {
                                            _selectedSeatCount =
                                                availableSeats.first;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<int>(
                                    value: _selectedSeatCount,
                                    decoration: InputDecoration(
                                      labelText: 'Số chỗ ngồi *',
                                      prefixIcon: const Icon(Icons.event_seat),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    items:
                                        _getAvailableSeatCounts().map((count) {
                                          return DropdownMenuItem(
                                            value: count,
                                            child: Text('$count chỗ'),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedSeatCount = value;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Vui lòng chọn số chỗ ngồi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            BusHelper.getSeatCountInfo(
                                              _selectedBusType,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<BusStatus>(
                                    value: _selectedStatus,
                                    decoration: InputDecoration(
                                      labelText: 'Trạng thái *',
                                      prefixIcon: const Icon(Icons.info),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    items:
                                        BusStatus.values.map((status) {
                                          return DropdownMenuItem(
                                            value: status,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  BusHelper.getStatusIcon(
                                                    status,
                                                  ),
                                                  size: 20,
                                                  color:
                                                      BusHelper.getStatusColor(
                                                        status,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  BusHelper.getStatusName(
                                                    status,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedStatus = value;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      busState is BusLoading
                                          ? null
                                          : () => _submitForm(user.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child:
                                      busState is BusLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text(
                                            'Cập nhật',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (busState is BusLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Đang cập nhật xe...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _submitForm(int companyId) {
    if (_formKey.currentState!.validate()) {
      final updatedBus = MBus(
        id: widget.bus.id,
        busNumber: _licensePlateController.text.trim(),
        type: _selectedBusType,
        seatCount: _selectedSeatCount,
        status: _selectedStatus,
        companyId: companyId,
      );

      context.read<BusCubit>().updateBus(widget.bus.id!, updatedBus);
    }
  }
}
