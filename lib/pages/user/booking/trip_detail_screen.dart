import 'package:bus_ticket_app/core/company/cubit/company_cubit.dart';
import 'package:bus_ticket_app/core/network/cubit/internet_connection_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/core/user/user_local_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:bus_ticket_app/utils/helper/bus_helper.dart';
import 'package:bus_ticket_app/utils/helper/seat_layout_helper.dart';
import 'package:go_router/go_router.dart';

class TripDetailScreen extends StatefulWidget {
  final MTrip trip;
  final MRoute route;
  final MBus bus;
  const TripDetailScreen({
    super.key,
    required this.trip,
    required this.route,
    required this.bus,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  String companyName = '';
  String companyEmail = '';
  String companyPhone = '';
  bool isOnline = false;
  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final internetState = context.read<InternetConnectionCubit>().state;
      if (internetState == InternetStatusState.connected) {
        isOnline = true;
      }
      if (isOnline) {
        context.read<CompanyCubit>().loadCompanyById(widget.bus.companyId!);
      } else {
        final companyUser = await UserLocalDatabase().getCompanyUserById(
          widget.bus.companyId!,
        );
        setState(() {
          companyName = companyUser?.fullName ?? '';
          companyEmail = companyUser?.email ?? '';
          companyPhone = companyUser?.phone ?? '';
        });
      }
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin nhà xe');
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration =
        widget.trip.arrivalTime != null && widget.trip.departureTime != null
            ? widget.trip.arrivalTime!.difference(widget.trip.departureTime!)
            : null;

    final durationText =
        duration != null
            ? '${duration.inHours}h ${duration.inMinutes.remainder(60)}m'
            : 'N/A';
    return BlocBuilder<CompanyCubit, UserState>(
      builder: (context, state) {
        if (isOnline && state is UserLoaded) {
          companyName = state.user.fullName ?? 'N/A';
          companyEmail = state.user.email ?? 'N/A';
          companyPhone = state.user.phone ?? 'N/A';
        } else if (!isOnline && state is UserLoaded) {
          companyName = companyName;
          companyEmail = companyEmail;
          companyPhone = companyPhone;
        }
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF00424B),
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/background_card.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              size: 60,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                '${widget.route.departure ?? 'N/A'} ➜ ${widget.route.destination ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${FormatHelper.formatCurrency(widget.trip.price!.toDouble())} đ/vé',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    BlocBuilder<InternetConnectionCubit, InternetStatusState>(
                      builder: (context, internetState) {
                        if (internetState == InternetStatusState.disconnected) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            color: Colors.orange.shade100,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bạn đang ở chế độ ngoại tuyến.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Thông tin thời gian',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            icon: Icons.flight_takeoff,
                            label: 'Thời gian khởi hành',
                            value:
                                widget.trip.departureTime != null
                                    ? DateFormat(
                                      'HH:mm - dd/MM/yyyy',
                                    ).format(widget.trip.departureTime!)
                                    : 'N/A',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.flight_land,
                            label: 'Thời gian đến nơi',
                            value:
                                widget.trip.arrivalTime != null
                                    ? DateFormat(
                                      'HH:mm - dd/MM/yyyy',
                                    ).format(widget.trip.arrivalTime!)
                                    : 'N/A',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.schedule,
                            label: 'Thời gian di chuyển',
                            value: durationText,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.home_work_rounded,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Thông tin nhà xe',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            icon: Icons.business_center,
                            label: 'Tên nhà xe',
                            value: companyName,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: 'Số điện thoại',
                            value: companyPhone,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: companyEmail,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Thông tin xe',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            icon: Icons.credit_card,
                            label: 'Biển số xe',
                            value: widget.bus.busNumber!,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.airline_seat_recline_normal,
                            label: 'Loại xe',
                            value: BusHelper.getBusTypeName(widget.bus.type),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.event_seat,
                            label: 'Số ghế',
                            value: widget.bus.seatCount!.toString(),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.check_circle_outline,
                            label: 'Ghế còn trống',
                            value:
                                '${SeatLayoutHelper.countAvailableSeats(widget.trip.seatLayout)} ghế',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
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
                    context.push(
                      '/user/seat-select',
                      extra: {
                        'trip': widget.trip,
                        'route': widget.route,
                        'bus': widget.bus,
                        'companyName': companyName,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đặt vé ngay',
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
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
