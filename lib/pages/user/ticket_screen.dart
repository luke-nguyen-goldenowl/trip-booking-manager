import 'package:bus_ticket_app/core/booking/cubit/booking_cubit.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_state.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/utils/ui/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/widgets/card_ticket.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/core/booking/ticket/ticket_service.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen>
    with TickerProviderStateMixin {
  TicketService ticketService = TicketService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  void _loadTickets() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      final userId = userState.user.id;
      context.read<BookingCubit>().getBookingbyUserId(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            tabs: const [Tab(text: 'Vé đã đặt'), Tab(text: 'Vé đã huỷ')],
          ),
        ),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return buildSkeletonLoading();
            } else if (state is BookingListLoaded) {
              final bookings = state.bookings;
              final activeTickets =
                  bookings
                      .where((booking) => booking.status != 'cancelled')
                      .toList();
              final cancelledTickets =
                  bookings
                      .where((booking) => booking.status == 'cancelled')
                      .toList();
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildListTickets(activeTickets),
                  _buildListTickets(cancelledTickets),
                ],
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadTickets();
                },
                child: ListView(
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: Text(
                        'Bạn không có vé nào.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildListTickets(List bookings) {
    if (bookings.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          _loadTickets();
        },
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final ticket = bookings[index];
            return FutureBuilder(
              future: ticketService.fetchFullTicketInfo(ticket),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: buildSkeletonLoading(),
                  );
                }
                final fullTicketInfo = snapshot.data!;
                return GestureDetector(
                  onTap: () {
                    context.push('/user/ticket-detail', extra: fullTicketInfo);
                  },
                  child: TicketSummaryCard(info: fullTicketInfo),
                );
              },
            );
          },
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          _loadTickets();
        },
        child: ListView(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Text(
                'Bạn không có vé nào.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }
  }
}
