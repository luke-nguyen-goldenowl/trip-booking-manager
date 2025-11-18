import 'package:bus_ticket_app/core/booking/cubit/booking_cubit.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_state.dart';
import 'package:bus_ticket_app/utils/helper/booking_helper.dart';
import 'package:bus_ticket_app/utils/helper/dialog_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/ticket_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.info});
  final MTicket info;

  @override
  Widget build(BuildContext context) {
    final paymentStatus = info.booking.paymentStatus;
    final status = info.booking.status;
    final qrData = jsonEncode({
      'bookingCode': info.booking.bookingCode,
      'userId': info.user.id,
      'userName': info.user.fullName,
      'userPhone': info.user.phone,
      'userEmail': info.user.email,
      'routeDeparture': info.route.departure,
      'routeDestination': info.route.destination,
      'busNumber': info.bus.busNumber,
      'seats': info.booking.seats,
      'paymentMethod': info.booking.paymentMethod!,
      'statusPayment': info.booking.paymentStatus!,
      'statusBooking': info.booking.status!,
    });
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Chi Tiết Vé',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF004049),
      ),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => Center(
                    child: CircularProgressIndicator(color: Colors.orange[300]),
                  ),
            );
          } else if (state is BookingInitial) {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hủy vé thành công'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            context.pop();
          } else if (state is BookingError) {
            Navigator.of(context).pop();
            DialogHelper.showError(
              context,
              title: 'Huỷ vé thất bại',
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[800]!, Colors.blue[600]!],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${info.company.fullName}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[200]!],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Bus Icon and Title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.directions_bus,
                                size: 60,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MÃ VÉ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    info.booking.bookingCode ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Route Information
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Điểm đi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    info.route.departure ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.blue[700],
                                size: 28,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Điểm đến',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    info.route.destination ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Details Grid
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Ngày đi',
                                FormatHelper.formatDate(
                                  info.trip.departureTime!,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _infoColumn(
                                'Giờ khởi hành',
                                FormatHelper.formatTime(
                                  info.trip.departureTime!,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Ghế',
                                BookingHelper.getSeatLabels(info.booking.seats),
                              ),
                            ),
                            Expanded(
                              child: _infoColumn(
                                'Biển số xe',
                                info.bus.busNumber ?? 'N/A',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Hành khách',
                                info.user.fullName ?? 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _infoColumn(
                                'Điện thoại',
                                info.user.phone ?? 'N/A',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Thời gian dặt vé',
                                FormatHelper.formatDateTime(
                                  info.booking.createdAt!.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Phương thức thanh toán',
                                BookingHelper.getPaymentMethodText(
                                  info.booking.paymentMethod!,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Trạng thái vé',
                                BookingHelper.getStatusText(
                                  info.booking.status!,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoColumn(
                                'Trạng thái thanh toán',
                                BookingHelper.getPaymentStatusText(
                                  info.booking.paymentStatus!,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng cộng',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${FormatHelper.formatCurrency(info.booking.totalPrice!.toDouble())} đ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        info.booking.status != 'cancelled'
                            ? QrImageView(data: qrData, size: 180)
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  paymentStatus == 'pending' && status != "cancelled"
                      ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _handleCancelTicket(context, info);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Huỷ Vé',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

void _handleCancelTicket(BuildContext context, MTicket info) {
  DialogHelper.showCancelledConfirmation(
    context,
    itemName: info.booking.bookingCode!,
  ).then((confirmed) {
    if (confirmed) {
      context.read<BookingCubit>().cancelBooking(info.booking.id!);
    }
  });
}
