import 'package:bus_ticket_app/core/booking/booking_local_database.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_cubit.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_state.dart';
import 'package:bus_ticket_app/core/network/cubit/internet_connection_cubit.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/widgets/card_ticket.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/core/booking/ticket/ticket_service.dart';
import 'package:bus_ticket_app/widgets/offline_ticket_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TicketService ticketService = TicketService();
  final UserService userService = UserService(Supabase.instance.client);
  late final TabController _tabController;
  List<MBooking> offlineTickets = [];
  List<MBooking> onlineTickets = [];
  int? userId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _checkConnection() async {
    final internetState = context.read<InternetConnectionCubit>().state;
    return internetState == InternetStatusState.connected;
  }

  Future<void> _loadTickets() async {
    try {
      final isOnline = await _checkConnection();
      userId = (await userService.getUserIdFromLocal())!;

      if (isOnline) {
        context.read<BookingCubit>().getBookingByUserId(userId!);
      } else {
        final offlineBookings = await BookingLocalDatabase().getOfflineBookings(
          userId!,
        );
        if (mounted) {
          setState(() {
            offlineTickets = offlineBookings;
          });
        }
      }
    } catch (e) {
      throw Exception('Lỗi tải vé');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vé Của Tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF004049),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Vé đã đặt'),
            Tab(text: 'Đã thanh toán'),
            Tab(text: 'Vé đã hủy'),
          ],
        ),
      ),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Đặt vé thành công!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vé của bạn đã được xác nhận',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _loadTickets();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          }
          if (state is BookingError) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Thất bại',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          }
        },
        builder: (context, state) {
          return Column(
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
                              'Bạn đang ở chế độ ngoại tuyến',
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
              Expanded(
                child: BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, state) {
                    if (state is BookingLoading) {
                      return buildSkeletonLoading();
                    }
                    if (state is BookingListLoaded) {
                      onlineTickets = state.bookings;
                    }

                    final allBookings = [...offlineTickets, ...onlineTickets];

                    final activeTickets =
                        allBookings
                            .where(
                              (booking) =>
                                  booking.status == 'completed' &&
                                  booking.paymentStatus == 'pending',
                            )
                            .toList();
                    final completedTickets =
                        allBookings
                            .where(
                              (booking) =>
                                  booking.status == 'completed' &&
                                  booking.paymentStatus == 'completed',
                            )
                            .toList();

                    final cancelledTickets =
                        allBookings
                            .where((booking) => booking.status == 'cancelled')
                            .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildListTickets(activeTickets),
                        _buildListTickets(completedTickets),
                        _buildListTickets(cancelledTickets),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTickets(List<MBooking> bookings) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTickets,
        child: ListView(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn không có vé nào.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final ticket = bookings[index];
          final isOffline = offlineTickets.any(
            (t) => t.bookingCode == ticket.bookingCode,
          );

          return _buildTicketItem(ticket, isOffline);
        },
      ),
    );
  }

  Widget _buildTicketItem(MBooking ticket, bool isOffline) {
    return FutureBuilder(
      future: ticketService.fetchFullTicketInfo(ticket),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: buildSkeletonLoading(),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final fullTicketInfo = snapshot.data!;
        if (isOffline) {
          return OfflineTicketCard(
            info: fullTicketInfo,
            ticket: ticket,
            onContinuePayment: () => _handleContinuePayment(ticket),
            onCancel: () => _handleCancelOfflineTicket(ticket),
            onTap: () {
              context.push('/user/ticket-detail', extra: fullTicketInfo);
            },
          );
        }
        return GestureDetector(
          onTap: () {
            context.push('/user/ticket-detail', extra: fullTicketInfo);
          },
          child: TicketSummaryCard(info: fullTicketInfo),
        );
      },
    );
  }

  Future<void> _handleContinuePayment(MBooking ticket) async {
    final isOnline = await _checkConnection();

    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng kết nối mạng để tiếp tục thanh toán!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      context.read<BookingCubit>().createBooking(ticket);
      await Future.delayed(const Duration(milliseconds: 500));
      if (ticket.id != null) {
        await BookingLocalDatabase().deleteOfflineTicket(ticket.id!);
      }

      if (mounted) {
        setState(() {
          offlineTickets.removeWhere(
            (t) => t.bookingCode == ticket.bookingCode,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleCancelOfflineTicket(MBooking ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận hủy vé'),
            content: const Text('Bạn có chắc chắn muốn hủy vé này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hủy vé'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      if (ticket.id != null) {
        await BookingLocalDatabase().deleteOfflineTicket(ticket.id!);
      }
      if (mounted) {
        setState(() {
          offlineTickets.removeWhere(
            (t) => t.bookingCode == ticket.bookingCode,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy vé thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
