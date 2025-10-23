import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:flutter/material.dart';

class BusHelper {
  static getBusTypeName(BusType type) {
    switch (type) {
      case BusType.limousine:
        return 'Limousine';
      case BusType.sleeper:
        return 'Giường nằm';
      case BusType.seater:
        return 'Ghế ngồi';
    }
  }

  static Color getStatusColor(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return Colors.green;
      case BusStatus.maintenance:
        return Colors.orange;
      case BusStatus.inactive:
        return Colors.red;
    }
  }

  static String getStatusName(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return 'Hoạt động';
      case BusStatus.maintenance:
        return 'Bảo trì';
      case BusStatus.inactive:
        return 'Ngưng hoạt động';
    }
  }

  static IconData getBusTypeIcon(BusType type) {
    switch (type) {
      case BusType.limousine:
        return Icons.airline_seat_individual_suite;
      case BusType.sleeper:
        return Icons.bed;
      case BusType.seater:
        return Icons.airline_seat_recline_normal;
    }
  }

  static IconData getStatusIcon(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return Icons.check_circle;
      case BusStatus.maintenance:
        return Icons.build_circle;
      case BusStatus.inactive:
        return Icons.cancel;
    }
  }

  static String getSeatCountInfo(BusType type) {
    switch (type) {
      case BusType.sleeper:
        return 'Xe giường nằm có: 40, 34, 24, 22 chỗ';
      case BusType.seater:
        return 'Xe ghế ngồi có: 45, 29, 16 chỗ';
      case BusType.limousine:
        return 'Limousine có: 16 chỗ';
    }
  }

  static String getRouteStatusName(BusRouteStatus status) {
    switch (status) {
      case BusRouteStatus.active:
        return 'Hoạt động';
      case BusRouteStatus.inactive:
        return 'Ngưng';
    }
  }

  static Color getRouteStatusColor(BusRouteStatus status) {
    switch (status) {
      case BusRouteStatus.active:
        return Colors.green;
      case BusRouteStatus.inactive:
        return Colors.red;
    }
  }

  static String getRouteType(int distance) {
    if (distance < 100) {
      return 'Tuyến ngắn';
    } else if (distance < 300) {
      return 'Tuyến trung bình';
    } else {
      return 'Tuyến dài';
    }
  }

  static String getTripStatusName(BusTripStatus status) {
    switch (status) {
      case BusTripStatus.scheduled:
        return 'Lên lịch';
      case BusTripStatus.completed:
        return 'Hoàn thành';
    }
  }

  static IconData getTripStatusIcon(BusTripStatus status) {
    switch (status) {
      case BusTripStatus.scheduled:
        return Icons.schedule;
      case BusTripStatus.completed:
        return Icons.check_circle;
    }
  }

  static Color getTripStatusColor(BusTripStatus status) {
    switch (status) {
      case BusTripStatus.scheduled:
        return Colors.blue;
      case BusTripStatus.completed:
        return Colors.green;
    }
  }

  static String getSeatLayoutFile(int seatCount, BusType busType) {
    if (busType == BusType.limousine) {
      return 'limousine_16.json';
    } else if (busType == BusType.sleeper) {
      return 'sleeper_$seatCount.json';
    } else {
      return 'seater_$seatCount.json';
    }
  }

  static String getSeatLayoutFilebyCount(int seatCount) {
    switch (seatCount) {
      case 16:
        return 'limousine_16.json';
      case 22:
        return 'sleeper_22.json';
      case 24:
        return 'sleeper_24.json';
      case 29:
        return 'seater_29.json';
      case 34:
        return 'sleeper_34.json';
      case 40:
        return 'sleeper_40.json';
      case 45:
        return 'seater_45.json';
      default:
        return 'seater_16.json';
    }
  }
}
