import 'package:flutter/material.dart';
import 'package:bus_ticket_app/pages/bus_company/home_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/profile_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_car/bus_car_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_route/bus_route_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_trip/bus_trip_screen.dart';

class HomeBusCompanyScreen extends StatefulWidget {
  const HomeBusCompanyScreen({super.key});

  @override
  State<HomeBusCompanyScreen> createState() => _HomeBusCompanyScreenState();
}

class _HomeBusCompanyScreenState extends State<HomeBusCompanyScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BusCarScreen(),
    const BusRouteScreen(),
    const BusTripScreen(),
    const ProfileBusCompanyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _getTitle(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.orange[300],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Colors.orange[300]!,
          buttonBackgroundColor: Colors.orange[300],
          height: 60,
          index: _selectedIndex,
          items: const [
            Icon(Icons.home, size: 25, color: Colors.white),
            Icon(Icons.directions_bus, size: 30, color: Colors.white),
            Icon(Icons.route, size: 30, color: Colors.white),
            Icon(Icons.location_on_sharp, size: 30, color: Colors.white),
            Icon(Icons.person, size: 25, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Trang Chủ';
      case 1:
        return 'Quản lý Xe';
      case 2:
        return 'Tuyến Đường';
      case 3:
        return 'Chuyến Đi';
      case 4:
        return 'Tài Khoản';
      default:
        return 'Trang Chủ';
    }
  }
}
