import 'package:bus_ticket_app/core/network/cubit/internet_connection_cubit.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:bus_ticket_app/utils/helper/seat_layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SeatSelectScreen extends StatefulWidget {
  final MTrip trip;
  final MRoute route;
  final MBus bus;
  final String? companyName;
  const SeatSelectScreen({
    super.key,
    required this.trip,
    required this.route,
    required this.bus,
    this.companyName,
  });

  @override
  State<SeatSelectScreen> createState() => _SeatSelectScreenState();
}

class _SeatSelectScreenState extends State<SeatSelectScreen> {
  final List<String> _selectedSeats = [];
  String _currentFloor = 'lower';
  bool _hasMultipleFloors = false;
  int get totalPrice {
    return (widget.trip.price ?? 0) * _selectedSeats.length;
  }

  @override
  void initState() {
    super.initState();
    _hasMultipleFloors = SeatLayoutHelper.hasMultipleFloors(
      widget.trip.seatLayout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF00424B),
        title: const Text(
          'Chọn chỗ ngồi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<InternetConnectionCubit, InternetStatusState>(
                    builder: (context, internetState) {
                      if (internetState == InternetStatusState.disconnected) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          color: Colors.orange.shade100,
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_off,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bạn đang ở chế độ ngoại tuyến.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.route.departure} → ${widget.route.destination}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${FormatHelper.formatTime(widget.trip.departureTime!)} ,',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              FormatHelper.formatDate(
                                widget.trip.departureTime!,
                              ),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.bus.busNumber ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.home_work,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.companyName ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNoteItem(Colors.grey[300]!, 'Trống'),
                        _buildNoteItem(Colors.red[300]!, 'Đã đặt'),
                      ],
                    ),
                  ),

                  if (_hasMultipleFloors) _buildFloorSelector(),

                  _buildSeatLayoutSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Số ghế: ${_selectedSeats.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${FormatHelper.formatCurrency(totalPrice.toDouble())} đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00424B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      _selectedSeats.isEmpty ? null : _handleContinueToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00424B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinueToPayment() {
    context.push(
      '/user/payment-method',
      extra: {
        'trip': widget.trip,
        'route': widget.route,
        'bus': widget.bus,
        'selectedSeats': _selectedSeats,
        'totalPrice': totalPrice,
      },
    );
  }

  Widget _buildSeatLayoutSection() {
    if (widget.trip.seatLayout == null) {
      return const SizedBox();
    }
    final seats = widget.trip.seatLayout!['seats'] as List<dynamic>;
    final currentFloorSeats =
        _hasMultipleFloors
            ? seats.where((seat) => seat['floor'] == _currentFloor).toList()
            : seats;
    final rows = widget.trip.seatLayout!['rows'] as int;
    final columns = widget.trip.seatLayout!['columns'] as int;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Tài xế',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: rows * columns,
            itemBuilder: (context, index) {
              final row = index ~/ columns;
              final column = index % columns;
              final seat = currentFloorSeats.firstWhere(
                (s) => s['row'] == row && s['column'] == column,
                orElse: () => null,
              );
              if (seat == null) {
                return const SizedBox();
              }

              final seatId = seat['id'] as String;
              final isBooked = seat['isBooked'] as bool? ?? false;
              final isSelected = _selectedSeats.contains(seatId);

              return _buildSeatItem(seatId, isBooked, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(String seatId, bool isBooked, bool isSelected) {
    Color backgroundColor;
    Color textColor;
    if (isBooked) {
      backgroundColor = Colors.red[300]!;
      textColor = Colors.white;
    } else if (isSelected) {
      backgroundColor = Colors.blue[400]!;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.black;
    }
    return InkWell(
      onTap:
          isBooked
              ? null
              : () {
                setState(() {
                  if (isSelected) {
                    _selectedSeats.remove(seatId);
                  } else {
                    _selectedSeats.add(seatId);
                  }
                });
              },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            seatId,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloorButton('lower', 'Tầng 1'),
          _buildFloorButton('upper', 'Tầng 2'),
        ],
      ),
    );
  }

  Widget _buildFloorButton(String floorKey, String label) {
    final bool isSelected = _currentFloor == floorKey;
    return Container(
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? const LinearGradient(
                  colors: [Color(0xFF00424B), Color(0xFF006B7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: isSelected ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFF00424B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentFloor = floorKey;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
