import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_cubit.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_home/function_helper/function_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _companyId;

  @override
  void initState() {
    super.initState();
    _initializeCompanyId();
  }

  void _initializeCompanyId() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      _companyId = userState.user.id;
    }
  }

  void _refreshData() {
    if (_companyId != null) {
      context.read<BusTripCubit>().loadTrips(_companyId!);
      context.read<BusRouteCubit>().loadRoutes(_companyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: BlocBuilder<BusTripCubit, BusTripState>(
          builder: (context, tripState) => _buildBody(tripState),
        ),
      ),
    );
  }

  Widget _buildBody(BusTripState tripState) {
    if (tripState is BusTripLoading) {
      return buildSkeletonLoading();
    }

    if (tripState is BusTripError) {
      return _buildErrorState(tripState.message);
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Lỗi: $message'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Map<int, MRoute> _buildRouteMap(BusRouteState routeState) {
    if (routeState is BusRouteLoaded) {
      return {for (var r in routeState.routes) r.id!: r};
    }
    return {};
  }

  Widget _buildDashboard(List<MTrip> allTrips, Map<int, MRoute> routeMap) {
    final todayTrips = FunctionHelper.getTodayTrips(allTrips);
    final stats = FunctionHelper.calculateDailyStats(todayTrips, routeMap);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildKPICards(stats),
        const SizedBox(height: 24),
        _buildRevenueChart(allTrips, routeMap),
        const SizedBox(height: 24),
        _buildTopRoutes(allTrips, routeMap),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.dashboard, size: 32, color: Colors.orange.shade700),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bảng Thống Kê',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(DateTime.now()),
              style: TextStyle(fontSize: 14, color: Colors.orange[700]),
            ),
          ],
        ),
      ),
      IconButton(
        icon: Icon(Icons.chevron_right_rounded, color: Colors.orange[700]),
        onPressed:
            () => {
              context.push(
                '/home-bus-company/home-detail-dashboard',
                extra: DateTime.now(),
              ),
            },
        tooltip: 'Xem chi tiết hôm nay',
        iconSize: 40,
      ),
    ],
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
              title: 'Doanh thu hôm nay',
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
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    ),
  );
}

Widget _buildRevenueChart(List<MTrip> allTrips, Map<int, MRoute> routeMap) {
  final todayStart = DateTime.now();
  final last7Days = List.generate(
    7,
    (index) => DateTime(
      todayStart.year,
      todayStart.month,
      todayStart.day,
    ).subtract(Duration(days: 6 - index)),
  );
  final revenueData =
      last7Days.map((day) {
        final dayEnd = day.add(const Duration(days: 1));
        final dayTrips =
            allTrips
                .where(
                  (trip) =>
                      trip.departureTime != null &&
                      trip.departureTime!.isAfter(day) &&
                      trip.departureTime!.isBefore(dayEnd),
                )
                .toList();
        return FunctionHelper.calculateRevenue(dayTrips, routeMap);
      }).toList();
  final maxRevenue =
      revenueData.isEmpty
          ? 1000000.0
          : revenueData.reduce((a, b) => a > b ? a : b);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.bar_chart,
          title: 'Doanh thu 7 ngày gần nhất',
          subtitle: 'Nhấn vào điểm để xem chi tiết',
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: _buildLineChart(last7Days, revenueData, maxRevenue),
        ),
      ],
    ),
  );
}

Widget _buildLineChart(
  List<DateTime> days,
  List<double> data,
  double maxValue,
) {
  return LineChart(
    LineChartData(
      lineTouchData: _buildLineTouchData(days),
      gridData: _buildGridData(maxValue),
      titlesData: _buildTitlesData(days),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (6).toDouble(),
      minY: 0,
      maxY: maxValue * 1.2,
      lineBarsData: [_buildLineBarData(data)],
    ),
  );
}

FlTitlesData _buildTitlesData(List<DateTime> days) {
  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        getTitlesWidget:
            (value, meta) => Text(
              FormatHelper.formatCurrency(value),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
      ),
    ),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          if (value.toInt() >= 0 && value.toInt() < days.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('dd/MM').format(days[value.toInt()]),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            );
          }
          return const Text('');
        },
      ),
    ),
  );
}

LineTouchData _buildLineTouchData(List<DateTime> days) {
  return LineTouchData(
    touchCallback: (event, response) {
      if (event is FlTapUpEvent && response != null) {
        final spot = response.lineBarSpots?.first;
        if (spot != null) {
          final index = spot.x.toInt();
          if (index >= 0 && index < days.length) {
            //_navigateToDailyStats(days[index]);
          }
        }
      }
    },
    touchTooltipData: LineTouchTooltipData(
      getTooltipItems:
          (spots) =>
              spots.map((spot) {
                final index = spot.x.toInt();
                return LineTooltipItem(
                  '${DateFormat('dd/MM').format(days[index])}\n${FormatHelper.formatCurrency(spot.y)} đ',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
    ),
  );
}

FlGridData _buildGridData(double maxValue) {
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: maxValue > 0 ? maxValue / 5 : 200000,
    getDrawingHorizontalLine:
        (value) =>
            FlLine(color: Colors.grey[300]!, strokeWidth: 1, dashArray: [5, 5]),
  );
}

LineChartBarData _buildLineBarData(List<double> data) {
  return LineChartBarData(
    spots:
        data
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
    isCurved: true,
    color: Colors.blue,
    barWidth: 3,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: true,
      getDotPainter:
          (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: Colors.blue,
          ),
    ),
    belowBarData: BarAreaData(
      show: true,
      color: Colors.blue[600]!.withValues(alpha: 0.1),
    ),
  );
}

Widget _buildTopRoutes(List<MTrip> allTrips, Map<int, MRoute> routeMap) {
  final routeStats = FunctionHelper.calculateRouteStats(allTrips, routeMap);
  final top5 = routeStats.take(5).toList();

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
        _buildSectionHeader(
          icon: Icons.emoji_events,
          iconColor: Colors.amber[700],
          title: 'Tuyến Đường Phổ Biến',
        ),
        const SizedBox(height: 16),
        if (top5.isEmpty)
          _buildEmptyState('Chưa có dữ liệu')
        else
          ...top5.asMap().entries.map(
            (e) => _buildTopRouteItem(e.key, e.value, routeMap),
          ),
      ],
    ),
  );
}

Widget _buildEmptyState(String message, {IconData? icon}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
          ],
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    ),
  );
}

Widget _buildTopRouteItem(
  int index,
  Map<String, dynamic> data,
  Map<int, MRoute> routeMap,
) {
  final routeId = data['routeId'] as int;
  final route = routeMap[routeId];
  final rankColors = [Colors.amber, Colors.grey, Colors.orange, Colors.blue];

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: index < 4 ? rankColors[index].shade100 : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: index < 4 ? rankColors[index].shade200 : Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        _buildRankBadge(index, rankColors),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route != null
                    ? '${route.departure ?? 'N/A'} → ${route.destination ?? 'N/A'}'
                    : 'Không rõ tuyến đường',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data['tripCount']} chuyến',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Doanh thu: ${FormatHelper.formatCurrency(data['revenue'] as double)} đ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildRankBadge(int index, List<MaterialColor> colors) {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: index < 4 ? colors[index].shade400 : Colors.teal,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _buildSectionHeader({
  required IconData icon,
  required String title,
  Color? iconColor,
  String? subtitle,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ],
  );
}
