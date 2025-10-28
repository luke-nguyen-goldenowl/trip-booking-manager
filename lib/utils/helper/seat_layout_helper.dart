import 'dart:convert';

class SeatLayoutHelper {
  static int countAvailableSeats(dynamic seatLayoutJson) {
    try {
      Map<String, dynamic> seatLayout;
      if (seatLayoutJson is String) {
        seatLayout = json.decode(seatLayoutJson) as Map<String, dynamic>;
      } else if (seatLayoutJson is Map<String, dynamic>) {
        seatLayout = seatLayoutJson;
      } else {
        return 0;
      }

      int availableCount = 0;
      final seats = seatLayout['seats'] as List<dynamic>?;
      if (seats == null) return 0;
      for (var seat in seats) {
        if (seat != null && seat is Map<String, dynamic>) {
          final isBooked = seat['isBooked'] as bool? ?? false;
          if (!isBooked) {
            availableCount++;
          }
        }
      }

      return availableCount;
    } catch (e) {
      return 0;
    }
  }
}
