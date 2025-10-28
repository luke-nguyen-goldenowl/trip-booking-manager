import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';

class BusTripAddScreen extends StatefulWidget {
  const BusTripAddScreen({super.key});

  @override
  State<BusTripAddScreen> createState() => _BusTripAddScreenState();
}

class _BusTripAddScreenState extends State<BusTripAddScreen> {
  final _formKey = GlobalKey<FormState>();
  MRoute? _selectedRoute;
  MBus? _selectedBus;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;
  BusTripStatus _selectedStatus = BusTripStatus.scheduled;
  List<MRoute> _activeRoutes = [];
  List<MBus> _activeBuses = [];
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Chuyến Đi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.orange[300],
      ),
      body: BlocConsumer<BusTripCubit, BusTripState>(
        listener: _handleTripStateChanges,
        builder: (context, tripState) => _buildBody(tripState),
      ),
    );
  }

  void _handleTripStateChanges(BuildContext context, BusTripState state) {
    if (state is BusTripLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Thêm chuyến đi thành công'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (state is BusTripError) {
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildBody(BusTripState tripState) {
    return Stack(
      children: [
        BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            if (userState is UserLoading) {
              return buildSkeletonLoading();
            }

            if (userState is! UserLoaded) {
              return _buildErrorState();
            }

            return _buildForm(userState.user, tripState);
          },
        ),
        if (tripState is BusTripLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(user, BusTripState tripState) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRouteAndBusCard(),
          const SizedBox(height: 16),
          _buildDateTimeCard(),
          const SizedBox(height: 16),
          _buildCardPrice(),
          const SizedBox(height: 10),
          _buildStatusCard(),
          const SizedBox(height: 24),
          _buildActionButtons(user.id),
        ],
      ),
    );
  }

  Widget _buildCardPrice() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Giá vé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Giá vé',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'VNĐ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Vui lòng nhập giá vé';
                }
                final price = int.tryParse(value!);
                if (price == null || price <= 0) {
                  return 'Giá vé phải lớn hơn 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteAndBusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Tuyến đường và Xe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRouteDropdown(),
            const SizedBox(height: 16),
            _buildBusDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return BlocBuilder<BusRouteCubit, BusRouteState>(
      builder: (context, state) {
        if (state is BusRouteLoaded) {
          _activeRoutes =
              state.routes
                  .where((r) => r.status == BusRouteStatus.active)
                  .toList();
        }
        return DropdownButtonFormField<MRoute>(
          value: _selectedRoute,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Tuyến đường *',
            prefixIcon: const Icon(Icons.alt_route),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            helperStyle: const TextStyle(fontSize: 11),
          ),
          items:
              _activeRoutes.map((route) {
                return DropdownMenuItem(
                  value: route,
                  child: Text(
                    '${route.departure} → ${route.destination}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRoute = value;
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn tuyến đường';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildBusDropdown() {
    return BlocBuilder<BusCubit, BusState>(
      builder: (context, state) {
        if (state is BusLoaded) {
          _activeBuses =
              state.buses.where((b) => b.status == BusStatus.active).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<MBus>(
              value: _selectedBus,
              hint: const Text('Chọn xe'),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Xe *',
                prefixIcon: const Icon(Icons.directions_bus),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                helperStyle: const TextStyle(fontSize: 11),
              ),
              items:
                  _activeBuses.map((bus) {
                    return DropdownMenuItem(
                      value: bus,
                      child: Text(
                        '${bus.busNumber} - ${BusHelper.getBusTypeName(bus.type)} (${bus.seatCount} chỗ)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBus = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn xe';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Thời gian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDateTimeField(
              label: 'Ngày khởi hành',
              icon: Icons.calendar_today,
              date: _departureDate,
              time: _departureTime,
              onDateTap: () => _selectDate(context, true),
              onTimeTap: () => _selectTime(context, true),
            ),
            const SizedBox(height: 16),
            _buildDateTimeField(
              label: 'Ngày đến',
              icon: Icons.event_available,
              date: _arrivalDate,
              time: _arrivalTime,
              onDateTap: () => _selectDate(context, false),
              onTimeTap: () => _selectTime(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00424B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: onDateTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date != null
                              ? '${date.day}/${date.month}/${date.year}'
                              : 'Chọn ngày',
                          style: TextStyle(
                            color: date != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: onTimeTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          time != null
                              ? '${time.hour}:${time.minute.toString().padLeft(2, '0')}'
                              : 'Giờ',
                          style: TextStyle(
                            color: time != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Trạng thái',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BusTripStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Trạng thái chuyến đi *',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items:
                  BusTripStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            BusHelper.getTripStatusIcon(status),
                            size: 20,
                            color: BusHelper.getTripStatusColor(status),
                          ),
                          const SizedBox(width: 8),
                          Text(BusHelper.getTripStatusName(status)),
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
    );
  }

  Widget _buildActionButtons(int companyId) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => {_resetForm()},
            label: const Text(
              'Hủy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _submitForm(companyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Thêm chuyến đi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
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
                Text('Đang thêm chuyến đi...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _arrivalDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = picked;
        } else {
          _arrivalTime = picked;
        }
      });
    }
  }

  Future<void> _loadSeatLayoutAndCreateTrip(
    DateTime departureDateTime,
    DateTime arrivalDateTime,
    int companyId,
  ) async {
    try {
      final seatLayoutFile = BusHelper.getSeatLayoutFile(
        _selectedBus!.seatCount ?? 0,
        _selectedBus!.type,
      );
      final String jsonString = await rootBundle.loadString(
        'assets/data/$seatLayoutFile',
      );
      final Map<String, dynamic> seatLayout = json.decode(jsonString);

      final trip = MTrip(
        routeId: _selectedRoute!.id,
        busId: _selectedBus!.id,
        companyId: companyId,
        departureTime: departureDateTime,
        arrivalTime: arrivalDateTime,
        status: _selectedStatus,
        seatLayout: seatLayout,
        price: int.parse(_priceController.text.trim()),
      );
      if (!mounted) return;
      await context.read<BusTripCubit>().createTrip(trip);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải sơ đồ ghế: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedRoute = null;
      _selectedBus = null;
      _departureDate = null;
      _departureTime = null;
      _arrivalDate = null;
      _arrivalTime = null;
      _selectedStatus = BusTripStatus.scheduled;
    });
    _formKey.currentState?.reset();
  }

  Future<bool> _checkValidation(int companyId) async {
    if (!_formKey.currentState!.validate()) return false;

    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày giờ khởi hành'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_arrivalDate == null || _arrivalTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày giờ đến'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final departureDateTime = _departureDateTime;
    final arrivalDateTime = _arrivalDateTime;
    if (arrivalDateTime.isBefore(departureDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian đến phải sau thời gian khởi hành'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final isAvailable = await context.read<BusTripCubit>().checkBusAvailability(
      busId: _selectedBus!.id!,
      departureTime: departureDateTime,
      arrivalTime: arrivalDateTime,
    );
    if (!mounted) return false;
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Xe đã có chuyến đi trùng lịch trong khoảng thời gian này',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  void _submitForm(int companyId) async {
    final isValid = await _checkValidation(companyId);
    if (!isValid) return;
    await _loadSeatLayoutAndCreateTrip(
      _departureDateTime,
      _arrivalDateTime,
      companyId,
    );
  }

  DateTime _buildDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime get _departureDateTime {
    return _buildDateTime(_departureDate!, _departureTime!);
  }

  DateTime get _arrivalDateTime {
    return _buildDateTime(_arrivalDate!, _arrivalTime!);
  }
}
