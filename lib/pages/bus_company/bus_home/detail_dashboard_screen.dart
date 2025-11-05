import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_cubit.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_state.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_home/function_helper/function_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeDetailDashboardScreen extends StatefulWidget {
  const HomeDetailDashboardScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<HomeDetailDashboardScreen> createState() =>
      _HomeDetailDashboardScreenState();
}

class _HomeDetailDashboardScreenState extends State<HomeDetailDashboardScreen> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.date;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null && picked != _currentDate) {
      setState(() {
        _currentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thống Kê Chi Tiết',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BusTripCubit, BusTripState>(
        builder: (context, tripState) => _buildBody(tripState),
      ),
    );
  }

  Widget _buildBody(BusTripState tripState) {
    if (tripState is BusTripLoading) {
      return buildSkeletonLoading();
    }

    if (tripState is BusTripError) {
      return Center(
        child: Text(
          'Lỗi tải dữ liệu',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (tripState is BusTripLoaded) {
      return BlocBuilder<BusRouteCubit, BusRouteState>(
        builder: (context, routeState) {
          final routeMap = _buildRouteMap(routeState);
          return _buildDashboard(tripState.trips, routeMap);
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Map<int, MRoute> _buildRouteMap(BusRouteState routeState) {
    if (routeState is BusRouteLoaded) {
      return {for (var r in routeState.routes) r.id!: r};
    }
    return {};
  }

  Widget _buildDashboard(List<MTrip> allTrips, Map<int, MRoute> routeMap) {
    final dayTrips = FunctionHelper.filterTripsForDate(allTrips, _currentDate);
    final stats = FunctionHelper.calculateDailyStats(dayTrips, routeMap);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPickerDate(),
        const SizedBox(height: 24),
        _buildKPICards(stats),
        const SizedBox(height: 24),
        _buildRevenueTrip(dayTrips, routeMap),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPickerDate() {
    final isToday = FunctionHelper.isSameDay(_currentDate, DateTime.now());
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Hôm nay' : 'Ngày đã chọn',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatHelper.formatDate(_currentDate),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(Map<String, dynamic> stats) {
    final revenue = stats['revenue'] as double;
    final bookedSeats = stats['bookedSeats'] as int;
    final tripCount = stats['tripCount'] as int;
    final occupancyRate = stats['occupancyRate'] as double;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Doanh thu',
                value: FormatHelper.formatCurrency(revenue),
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: 'VNĐ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'Vé đã bán',
                value: bookedSeats.toString(),
                icon: Icons.confirmation_number,
                color: Colors.blue,
                subtitle: 'vé',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Chuyến hôm nay',
                value: tripCount.toString(),
                icon: Icons.directions_bus,
                color: Colors.orange,
                subtitle: 'chuyến',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'Tỷ lệ lấp đầy',
                value: '${occupancyRate.toStringAsFixed(1)}%',
                icon: Icons.people,
                color: Colors.red,
                subtitle: 'trung bình',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green[400], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrip(List<MTrip> dayTrips, Map<int, MRoute> routeMap) {
    // Sắp xếp các chuyến xe theo thời gian khởi hành
    final sortedTrips = [...dayTrips]
      ..sort((a, b) => a.departureTime!.compareTo(b.departureTime!));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus, color: Colors.purple[700]!),
              const SizedBox(width: 8),
              Text(
                'Danh Sách Chuyến Xe',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedTrips.isEmpty)
            Center(
              child: Text(
                'Không có chuyến nào trong ngày ${FormatHelper.formatDate(_currentDate)}',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ...sortedTrips.asMap().entries.map((entry) {
              final trip = entry.value;
              final route = routeMap[trip.routeId];
              print(route);

              // Tính doanh thu cho chuyến xe này
              final seatStats = FunctionHelper.getTripSeatStats(trip);
              print(seatStats);
              final bookedSeats = seatStats['booked'] ?? 0;
              print(bookedSeats);
              final tripRevenue = (trip.price ?? 0.0) * bookedSeats.toDouble();
              print(tripRevenue);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${route?.departure ?? 'N/A'} → ${route?.destination ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Khởi hành: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          FormatHelper.formatTime(trip.departureTime),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Đến: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          FormatHelper.formatTime(trip.arrivalTime),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.money, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Giá vé: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${FormatHelper.formatCurrency(trip.price!.toDouble())} VNĐ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Doanh thu: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${FormatHelper.formatCurrency(tripRevenue)} VNĐ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
