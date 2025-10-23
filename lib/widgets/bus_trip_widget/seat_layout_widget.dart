import 'package:flutter/material.dart';

class SeatLayoutWidget extends StatefulWidget {
  final Map<String, dynamic> seatLayout;

  const SeatLayoutWidget({super.key, required this.seatLayout});

  @override
  State<SeatLayoutWidget> createState() => _SeatLayoutWidgetState();
}

class _SeatLayoutWidgetState extends State<SeatLayoutWidget> {
  int _currentFloor = 1;

  @override
  Widget build(BuildContext context) {
    final busType = widget.seatLayout['busType'] as String?;
    final seats = widget.seatLayout['seats'] as List?;
    final rows = widget.seatLayout['rows'] as int?;
    final columns = widget.seatLayout['columns'] as int?;

    if (seats == null || seats.isEmpty || rows == null || columns == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (_hasMultipleFloors()) _buildFloorSelector(),
        if (_hasMultipleFloors()) const SizedBox(height: 16),
        _buildDriverIndicator(),
        const SizedBox(height: 16),
        _buildSeatGrid(busType, seats, rows, columns),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  bool _hasMultipleFloors() {
    final busType = widget.seatLayout['busType'] as String?;
    return busType == 'sleeper';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.event_seat, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có sơ đồ ghế',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.airline_seat_recline_normal, size: 20),
            SizedBox(width: 4),
            Text('Lái xe', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            [1, 2].map((floorNum) {
              final isSelected = _currentFloor == floorNum;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentFloor = floorNum;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Tầng $floorNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.blue,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSeatGrid(String? busType, List seats, int rows, int columns) {
    if (busType == 'sleeper') {
      return _buildSleeperLayout(seats, rows, columns);
    } else {
      return _buildSeaterLayout(seats, rows, columns);
    }
  }

  Widget _buildSleeperLayout(List seats, int rows, int columns) {
    final floorSeats =
        seats.where((seat) {
          final floor = seat['floor'] as String?;
          return _currentFloor == 1 ? floor == 'lower' : floor == 'upper';
        }).toList();

    Map<int, List<Map<String, dynamic>>> seatsByRow = {};
    for (var seat in floorSeats) {
      final row = seat['row'] as int;
      if (!seatsByRow.containsKey(row)) {
        seatsByRow[row] = [];
      }
      seatsByRow[row]!.add(seat as Map<String, dynamic>);
    }

    final sortedRows = seatsByRow.keys.toList()..sort();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children:
              sortedRows.map((rowIndex) {
                final rowSeats = seatsByRow[rowIndex]!;
                rowSeats.sort(
                  (a, b) => (a['column'] as int).compareTo(b['column'] as int),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        rowSeats
                            .map(
                              (seat) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: _buildSleeperSeat(seat),
                              ),
                            )
                            .toList(),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildSeaterLayout(List seats, int rows, int columns) {
    Map<int, Map<int, Map<String, dynamic>>> seatsByRow = {};
    for (var seat in seats) {
      final row = seat['row'] as int;
      final column = seat['column'] as int;
      if (!seatsByRow.containsKey(row)) {
        seatsByRow[row] = {};
      }
      seatsByRow[row]![column] = seat as Map<String, dynamic>;
    }

    final sortedRows = seatsByRow.keys.toList()..sort();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children:
              sortedRows.map((rowIndex) {
                final rowData = seatsByRow[rowIndex]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List.generate(columns, (colIndex) {
                          if (colIndex == 2 && rowIndex != sortedRows.last) {
                            return const SizedBox(width: 44);
                          }

                          final seat = rowData[colIndex];
                          if (seat == null) {
                            return const SizedBox(width: 44);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _buildSeaterSeat(seat),
                          );
                        }).toList(),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildSleeperSeat(Map<String, dynamic> seat) {
    final seatId = seat['id'] as String?;
    final isBooked = seat['isBooked'] as bool? ?? false;

    return Container(
      width: 70,
      height: 35,
      decoration: BoxDecoration(
        color: isBooked ? Colors.red.shade100 : Colors.green.shade100,
        border: Border.all(
          color: isBooked ? Colors.red : Colors.green,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          seatId ?? '',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isBooked ? Colors.red.shade800 : Colors.green.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildSeaterSeat(Map<String, dynamic> seat) {
    final seatId = seat['id'] as String?;
    final isBooked = seat['isBooked'] as bool? ?? false;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isBooked ? Colors.red.shade100 : Colors.green.shade100,
        border: Border.all(
          color: isBooked ? Colors.red : Colors.green,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          seatId ?? '',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isBooked ? Colors.red.shade800 : Colors.green.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Colors.green, 'Ghế trống'),
          const SizedBox(width: 20),
          _buildLegendItem(Colors.red, 'Ghế đã đặt'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
