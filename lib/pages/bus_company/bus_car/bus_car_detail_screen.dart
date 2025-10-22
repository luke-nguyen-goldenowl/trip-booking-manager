import 'package:flutter/material.dart';
import 'package:bus_ticket_app/models/MBus.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';

class BusCarDetailScreen extends StatefulWidget {
  final MBus bus;

  const BusCarDetailScreen({super.key, required this.bus});

  @override
  State<BusCarDetailScreen> createState() => _BusCarDetailScreenState();
}

class _BusCarDetailScreenState extends State<BusCarDetailScreen> {
  int _currentFloor = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết xe',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.orange[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              context.push('/home-bus-company/bus-car-edit', extra: widget.bus);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusInfoCard(),
            const SizedBox(height: 16),
            _buildSeatMapSection(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBusInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bus.busNumber ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00424B),
                        ),
                      ),
                      _buildStatusChip(widget.bus.status),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.event_seat,
              'Số ghế',
              '${widget.bus.seatCount} chỗ',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              'Loại xe',
              BusHelper.getBusTypeName(widget.bus.type),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.info,
              'Trạng thái',
              BusHelper.getStatusName(widget.bus.status),
              color: BusHelper.getStatusColor(widget.bus.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color ?? const Color(0xFF00424B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatMapSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sơ đồ ghế',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00424B),
                  ),
                ),
                if (widget.bus.type == BusType.sleeper) _buildFloorSelector(),
              ],
            ),
            const SizedBox(height: 20),

            Center(
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
            ),
            const SizedBox(height: 16),

            _buildSeatLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloorButton(1, 'Tầng 1'),
          _buildFloorButton(2, 'Tầng 2'),
        ],
      ),
    );
  }

  Widget _buildFloorButton(int floor, String label) {
    final isSelected = _currentFloor == floor;
    return InkWell(
      onTap: () => setState(() => _currentFloor = floor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.orange,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatLayout() {
    switch (widget.bus.type) {
      case BusType.sleeper:
        return _buildSleeperLayout();
      case BusType.seater:
        return _buildSeaterLayout();
      case BusType.limousine:
        return _buildLimousineLayout();
    }
  }

  Widget _buildSleeperLayout() {
    final seatCount = widget.bus.seatCount ?? 22;
    final seatsPerFloor = seatCount ~/ 2;
    final rows = (seatsPerFloor / 3).ceil();

    int seatNumber = _currentFloor == 1 ? 1 : seatsPerFloor + 1;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (colIndex) {
              if (seatNumber >
                  (_currentFloor == 1 ? seatsPerFloor : seatCount)) {
                return const SizedBox(width: 60, height: 80);
              }
              return _buildSleeperSeat(seatNumber++, colIndex);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSleeperSeat(int number, int colIndex) {
    return Container(
      width: 60,
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: colIndex == 1 ? 4 : 2),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel, size: 20, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            '$number',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeaterLayout() {
    final seatCount = widget.bus.seatCount ?? 29;
    final lastRowSeats = 5;
    final regularSeats = seatCount - lastRowSeats;
    final regularRows = (regularSeats / 4).ceil();

    int seatNumber = 1;

    return Column(
      children: [
        ...List.generate(regularRows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSeaterSeat(seatNumber++),
                const SizedBox(width: 4),
                _buildSeaterSeat(seatNumber++),
                const SizedBox(width: 24),
                _buildSeaterSeat(seatNumber++),
                const SizedBox(width: 4),
                _buildSeaterSeat(seatNumber++),
              ],
            ),
          );
        }),

        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSeaterSeat(seatNumber++),
              const SizedBox(width: 4),
              _buildSeaterSeat(seatNumber++),
              const SizedBox(width: 4),
              _buildSeaterSeat(seatNumber++),
              const SizedBox(width: 4),
              _buildSeaterSeat(seatNumber++),
              const SizedBox(width: 4),
              _buildSeaterSeat(seatNumber++),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeaterSeat(int number) {
    return Container(
      width: 45,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_seat, size: 18, color: Colors.green),
          Text(
            '$number',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimousineLayout() {
    final seatCount = 16;
    final lastRowSeats = 5;
    final regularSeats = seatCount - lastRowSeats;
    final regularRows = (regularSeats / 4).ceil();

    int seatNumber = 1;

    return Column(
      children: [
        ...List.generate(regularRows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLimousineSeat(seatNumber++),
                const SizedBox(width: 4),
                _buildLimousineSeat(seatNumber++),
                const SizedBox(width: 24),
                _buildLimousineSeat(seatNumber++),
                const SizedBox(width: 4),
                _buildLimousineSeat(seatNumber++),
              ],
            ),
          );
        }),

        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLimousineSeat(seatNumber++),
              const SizedBox(width: 4),
              _buildLimousineSeat(seatNumber++),
              const SizedBox(width: 4),
              _buildLimousineSeat(seatNumber++),
              const SizedBox(width: 4),
              if (seatNumber <= seatCount) _buildLimousineSeat(seatNumber++),
              const SizedBox(width: 4),
              if (seatNumber <= seatCount) _buildLimousineSeat(seatNumber++),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimousineSeat(int number) {
    return Container(
      width: 50,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.airline_seat_flat, size: 20, color: Colors.purple),
          Text(
            '$number',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chú thích',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00424B),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              widget.bus.type == BusType.sleeper
                  ? Colors.blue
                  : widget.bus.type == BusType.seater
                  ? Colors.green
                  : Colors.purple,
              BusHelper.getBusTypeName(widget.bus.type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusChip(BusStatus status) {
    Color color;
    String text;

    switch (status) {
      case BusStatus.active:
        color = Colors.green;
        text = 'Hoạt động';
        break;
      case BusStatus.maintenance:
        color = Colors.orange;
        text = 'Bảo trì';
        break;
      case BusStatus.inactive:
        color = Colors.red;
        text = 'Ngưng';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
