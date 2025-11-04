import 'package:bus_ticket_app/core/booking/booking_local_database.dart';
import 'package:bus_ticket_app/core/network/cubit/internet_connection_cubit.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_cubit.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_state.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends StatefulWidget {
  final MTrip trip;
  final MRoute route;
  final MBus bus;
  final List<String> selectedSeats;
  final int totalPrice;

  const PaymentScreen({
    super.key,
    required this.trip,
    required this.route,
    required this.bus,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int userId = 0;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    UserService userService = UserService();
    userId = (await userService.getUserIdFromLocal())!;
  }

  BookingPaymentMethod _selectedPaymentMethod = BookingPaymentMethod.cash;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Phương thức thanh toán',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF00424B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            context.go(
              '/user/booking-success',
              extra: {
                'booking': state.booking,
                'route': widget.route,
                'bus': widget.bus,
                'trip': widget.trip,
              },
            );
          } else if (state is BookingPending) {
            context.go(
              '/user/booking-pending',
              extra: {
                'booking': state.booking,
                'route': widget.route,
                'bus': widget.bus,
                'trip': widget.trip,
              },
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SummaryTripCard(widget: widget),

                    SeatSelectedSection(widget: widget),

                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                          const Text(
                            'Chọn phương thức thanh toán',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOption(
                            method: BookingPaymentMethod.cash,
                            icon: Icons.money,
                            iconColor: Colors.green,
                            title: 'Tiền mặt',
                            subtitle: 'Thanh toán khi lên xe',
                          ),
                          const SizedBox(height: 8),
                          _buildPaymentOption(
                            method: BookingPaymentMethod.momo,
                            icon: Icons.wallet,
                            iconColor: Colors.pink,
                            title: 'MoMo',
                            subtitle: 'Thanh toán qua ví MoMo',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      '${FormatHelper.formatCurrency(widget.totalPrice.toDouble())} đ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00424B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, state) {
                    if (state is BookingLoading) {
                      isLoading = true;
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00424B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Xác nhận đặt vé',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _checkConnection() async {
    final internetState = context.read<InternetConnectionCubit>().state;
    if (internetState == InternetStatusState.connected) {
      return true;
    }
    return false;
  }

  void _createBooking() async {
    final booking = MBooking(
      userId: userId,
      tripId: widget.trip.id,
      totalPrice: widget.totalPrice,
      status: BookingStatus.pending.value,
      paymentMethod: _selectedPaymentMethod.value,
      seats: widget.selectedSeats.join(','),
      bookingCode:
          'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}',
      createdAt: DateTime.now(),
      isMailSended: false,
    );
    final isOnline = await _checkConnection();
    if (isOnline) {
      context.read<BookingCubit>().createBooking(booking);
    } else {
      try {
        setState(() {
          isLoading = true;
        });
        await BookingLocalDatabase().saveOfflineBooking(booking);
        if (!mounted) return;
        DialogHelper.showSuccess(
          context,
          title: 'Đặt vé thành công',
          message:
              'Vé của bạn đã được lưu ngoại tuyến. Vui lòng kết nối Internet để tiếp tục thanh toán.',
        );
        setState(() {
          isLoading = false;
        });
        Future.delayed(const Duration(seconds: 4), () {
          context.go('/tickets');
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi lưu vé ngoại tuyến.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPaymentOption({
    required BookingPaymentMethod method,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[50] : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue[900] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue, size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}

class SummaryTripCard extends StatelessWidget {
  const SummaryTripCard({super.key, required this.widget});

  final PaymentScreen widget;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Thông tin chuyến đi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.route.departure ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          FormatHelper.formatTime(widget.trip.departureTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormatHelper.formatDate(widget.trip.departureTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.route.destination ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          FormatHelper.formatTime(widget.trip.arrivalTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormatHelper.formatDate(widget.trip.arrivalTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
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
}

class SeatSelectedSection extends StatelessWidget {
  const SeatSelectedSection({super.key, required this.widget});

  final PaymentScreen widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Row(
            children: [
              const Icon(Icons.event_seat, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Ghế đã chọn (${widget.selectedSeats.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.selectedSeats.map((seatId) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      seatId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
