import 'package:bus_ticket_app/utils/helper/vietnamese_format_unit.dart';
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
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:intl/intl.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';

class BusTripEditScreen extends StatefulWidget {
  final MTrip trip;

  const BusTripEditScreen({super.key, required this.trip});

  @override
  State<BusTripEditScreen> createState() => _BusTripEditScreenState();
}

class _BusTripEditScreenState extends State<BusTripEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  MRoute? _selectedRoute;
  MBus? _selectedBus;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;
  BusTripStatus? _selectedStatus;
  List<MRoute> _activeRoutes = [];
  List<MBus> _activeBuses = [];
  int? price;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _selectedStatus = widget.trip.status;
    if (widget.trip.price != null) {
      _priceController.text = widget.trip.price.toString();
    }
    if (widget.trip.departureTime != null) {
      _departureDate = DateTime(
        widget.trip.departureTime!.year,
        widget.trip.departureTime!.month,
        widget.trip.departureTime!.day,
      );
      _departureTime = TimeOfDay(
        hour: widget.trip.departureTime!.hour,
        minute: widget.trip.departureTime!.minute,
      );
    }
    if (widget.trip.arrivalTime != null) {
      _arrivalDate = DateTime(
        widget.trip.arrivalTime!.year,
        widget.trip.arrivalTime!.month,
        widget.trip.arrivalTime!.day,
      );
      _arrivalTime = TimeOfDay(
        hour: widget.trip.arrivalTime!.hour,
        minute: widget.trip.arrivalTime!.minute,
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusTripCubit, BusTripState>(
      listener: _handleBusTripStateChanges,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chỉnh sửa chuyến đi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final confirmed = await DialogHelper.showConfirmation(
                context,
                title: 'Thông Báo',
                message:
                    'Bạn chắn chắn với sự thay đổi và muốn quay lại trang trước?',
                icon: Icons.cancel,
                iconColor: Colors.red,
                confirmColor: Colors.red,
              );
              if (confirmed && mounted) {
                context.pop();
              }
            },
          ),
          backgroundColor: Colors.orange[300],
        ),
        body: BlocBuilder<BusTripCubit, BusTripState>(
          builder: (context, tripState) {
            final isLoading = tripState is BusTripLoading;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRouteDropdown(),
                        const SizedBox(height: 16),
                        _buildBusDropdown(),
                        const SizedBox(height: 16),
                        _buildDepartureSection(),
                        const SizedBox(height: 16),
                        _buildArrivalSection(),
                        const SizedBox(height: 16),
                        _buildPriceField(),
                        const SizedBox(height: 16),
                        _buildStatusDropdown(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBusTripStateChanges(BuildContext context, BusTripState state) {
    if (state is BusTripLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật chuyến đi thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is BusTripError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giá vé',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [VietnameseThousandsFormatter()],
          decoration: InputDecoration(
            hintText: 'Nhập giá vé',
            suffixText: 'VNĐ',
            prefixIcon: const Icon(Icons.attach_money, color: Colors.orange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Vui lòng nhập giá vé';
            }
            price = int.tryParse(value!.replaceAll(RegExp(r'[^0-9]'), ''));
            if (price == null || price! <= 0) {
              return 'Giá vé phải lớn hơn 0';
            }
            return null;
          },
        ),
      ],
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
          if (_selectedRoute == null && widget.trip.routeId != null) {
            _selectedRoute = _activeRoutes.firstWhere(
              (r) => r.id == widget.trip.routeId,
              orElse:
                  () =>
                      _activeRoutes.isNotEmpty
                          ? _activeRoutes.first
                          : MRoute(status: BusRouteStatus.active),
            );
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tuyến đường',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MRoute>(
              value: _selectedRoute,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Chọn tuyến đường',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  _activeRoutes.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text('${route.departure} - ${route.destination}'),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoute = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn tuyến đường';
                }
                return null;
              },
            ),
          ],
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
          if (_selectedBus == null && widget.trip.busId != null) {
            _selectedBus = _activeBuses.firstWhere(
              (b) => b.id == widget.trip.busId,
              orElse:
                  () =>
                      _activeBuses.isNotEmpty
                          ? _activeBuses.first
                          : MBus(
                            type: BusType.seater,
                            status: BusStatus.active,
                          ),
            );
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MBus>(
              value: _selectedBus,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Chọn xe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  _activeBuses.map((bus) {
                    return DropdownMenuItem(
                      value: bus,
                      child: Text(
                        '${bus.busNumber} - ${BusHelper.getBusTypeName(bus.type)} (${bus.seatCount} ghế)',
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBus = value;
                });
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

  Widget _buildDepartureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khởi hành',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDepartureDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _departureDate != null
                        ? DateFormat('dd/MM/yyyy').format(_departureDate!)
                        : 'Chọn ngày',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectDepartureTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Giờ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _departureTime != null
                        ? _departureTime!.format(context)
                        : 'Chọn giờ',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArrivalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đến nơi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectArrivalDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _arrivalDate != null
                        ? DateFormat('dd/MM/yyyy').format(_arrivalDate!)
                        : 'Chọn ngày',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectArrivalTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Giờ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _arrivalTime != null
                        ? _arrivalTime!.format(context)
                        : 'Chọn giờ',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trạng thái',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<BusTripStatus>(
          value: _selectedStatus,
          decoration: InputDecoration(
            hintText: 'Chọn trạng thái',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items:
              BusTripStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(BusHelper.getTripStatusName(status)),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Cập nhật chuyến đi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _departureDate) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  Future<void> _selectDepartureTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _departureTime) {
      setState(() {
        _departureTime = picked;
      });
    }
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _arrivalDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _arrivalDate) {
      setState(() {
        _arrivalDate = picked;
      });
    }
  }

  Future<bool> _checkValidation() async {
    if (!_formKey.currentState!.validate()) return false;
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

    if (_selectedBus!.id! != widget.trip.busId) {
      final isAvailable = await context
          .read<BusTripCubit>()
          .checkBusAvailability(
            busId: _selectedBus!.id!,
            departureTime: departureDateTime,
            arrivalTime: arrivalDateTime,
            excludeTripId: widget.trip.id,
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
    }
    return true;
  }

  void _submitForm() async {
    final isValid = await _checkValidation();
    if (!isValid) return;
    await _loadSeatLayoutAndUpdateTrip(_departureDateTime, _arrivalDateTime);
  }

  Future<void> _loadSeatLayoutAndUpdateTrip(
    DateTime departureDateTime,
    DateTime arrivalDateTime,
  ) async {
    try {
      final seatLayoutFile = BusHelper.getSeatLayoutFilebyCount(
        _selectedBus!.seatCount ?? 0,
      );
      final String jsonString = await rootBundle.loadString(
        'assets/data/$seatLayoutFile',
      );
      final Map<String, dynamic> seatLayout = json.decode(jsonString);

      _updateTrip(departureDateTime, arrivalDateTime, seatLayout);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu sơ đồ ghế: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateTrip(
    DateTime departureDateTime,
    DateTime arrivalDateTime,
    Map<String, dynamic>? seatLayout,
  ) {
    final updatedTrip = widget.trip.copyWith(
      routeId: _selectedRoute!.id,
      busId: _selectedBus!.id,
      departureTime: departureDateTime,
      arrivalTime: arrivalDateTime,
      status: _selectedStatus,
      seatLayout: seatLayout,
      price: price!,
    );

    context.read<BusTripCubit>().updateTrip(widget.trip.id!, updatedTrip);
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _arrivalTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _arrivalTime) {
      setState(() {
        _arrivalTime = picked;
      });
    }
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
