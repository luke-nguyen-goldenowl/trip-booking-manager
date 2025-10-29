import 'package:flutter/material.dart';
import 'dart:convert';

class BookingHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'paid':
        return 'Đã thanh toán';
      case 'pending':
        return 'Chờ xử lý';
      case 'cancelled':
        return 'Đã hủy';
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
      case 'vnpay':
        return 'VNPay';
      case 'bank_transfer':
        return 'Chuyển khoản';
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
