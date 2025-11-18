import 'package:flutter/material.dart';
import 'dart:convert';

class BookingHelper {
  static Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Đã đặt';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  static String getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'completed':
        return 'Đã thanh toán';
      default:
        return status;
    }
  }

  static String getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tiền mặt';
      case 'momo':
        return 'Ví MoMo';
      default:
        return method;
    }
  }

  static String getSeatLabels(String? seats) {
    if (seats == null || seats.isEmpty) {
      return 'N/A';
    }
    try {
      final seatsList = jsonDecode(seats) as List;
      return seatsList.join(', ');
    } catch (e) {
      return seats;
    }
  }
}
