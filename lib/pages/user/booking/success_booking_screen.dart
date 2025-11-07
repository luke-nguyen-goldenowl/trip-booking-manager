import 'package:bus_ticket_app/core/company/cubit/company_cubit.dart';
import 'package:bus_ticket_app/utils/helper/booking_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:go_router/go_router.dart';

class SuccessBookingScreen extends StatefulWidget {
  final MBooking booking;
  final MTrip trip;
  final MRoute route;
  final MBus bus;
  const SuccessBookingScreen({
    super.key,
    required this.booking,
    required this.trip,
    required this.route,
    required this.bus,
  });

  @override
  State<SuccessBookingScreen> createState() => _SuccessBookingScreenState();
}

class _SuccessBookingScreenState extends State<SuccessBookingScreen> {
  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  void _loadCompanyInfo() {
    try {
      context.read<CompanyCubit>().loadCompanyById(widget.bus.companyId!);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(75),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Đặt vé thành công!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vé của bạn đã được đặt thành công',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thông tin đặt vé',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: BookingHelper.getPaymentStatusColor(
                                    widget.booking.paymentStatus ?? 'pending',
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  BookingHelper.getPaymentStatusText(
                                    widget.booking.paymentStatus ?? 'pending',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildInfoRow(
                            Icons.confirmation_number_outlined,
                            'Mã đặt vé',
                            widget.booking.bookingCode ?? 'N/A',
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.route,
                            'Tuyến đường',
                            '${widget.route.departure} → ${widget.route.destination}',
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.event_seat,
                            'Ghế đã chọn',
                            BookingHelper.getSeatLabels(widget.booking.seats),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<CompanyCubit, UserState>(
                            builder: (context, state) {
                              String companyName = '';
                              if (state is UserLoaded) {
                                companyName = state.user.fullName!;
                              }
                              return _buildInfoRow(
                                Icons.business,
                                'Nhà xe',
                                companyName,
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.directions_bus,
                            'Biển số xe',
                            widget.bus.busNumber ?? 'N/A',
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.calendar_today,
                            'Ngày đặt',
                            widget.booking.createdAt != null
                                ? DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(widget.booking.createdAt!)
                                : 'N/A',
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.payment,
                            'Phương thức',
                            BookingHelper.getPaymentMethodText(
                              widget.booking.paymentMethod ?? 'cash',
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng tiền',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${FormatHelper.formatCurrency(widget.booking.totalPrice!.toDouble())} VNĐ',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child:
                                widget.booking.paymentMethod == 'cash'
                                    ? Text(
                                      'Vui lòng đến bến xe trước 15 phút để làm thủ tục và thanh toán tiền mặt cho nhân viên khi lên xe.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    )
                                    : Text(
                                      'Thanh toán của bạn đã được xử lý thành công.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(16),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/tickets');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00424B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Xem vé của tôi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
