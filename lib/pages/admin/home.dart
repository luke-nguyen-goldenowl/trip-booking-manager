import 'package:flutter/material.dart';
import 'package:bus_ticket_app/pages/admin/home_screen.dart';
import 'package:bus_ticket_app/pages/admin/profile_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    // const MyTicketsTab(),
    // const FavoriteTab(),
    const ProfileAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _getTitle(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.teal,
        buttonBackgroundColor: Colors.teal,
        height: 60,
        index: _selectedIndex,
        items: const [
          Icon(Icons.home, size: 25, color: Colors.white),
          // Icon(Icons.confirmation_number, size: 30, color: Colors.white),
          // Icon(Icons.favorite, size: 30, color: Colors.white),
          Icon(Icons.person, size: 25, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Trang Chủ';
      // case 1:
      //   return 'Người dùng';
      // case 2:
      //   return 'Nhà xe';
      // case 1:
      //   return 'Chuyến';
      case 1:
        return 'Tài Khoản';
      default:
        return 'Trang Chủ';
    }
  }
}
