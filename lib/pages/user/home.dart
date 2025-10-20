import 'package:bus_ticket_app/pages/user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/pages/user/home_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:bus_ticket_app/pages/user/ticket_screen.dart';
import 'package:bus_ticket_app/pages/user/favorite_screen.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyTicketScreen(),
    const MyFavoriteScreen(),
    const ProfileUserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _getTitle(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.blue,
        buttonBackgroundColor: Colors.blue,
        height: 60,
        index: _selectedIndex,
        items: const [
          Icon(Icons.home, size: 25, color: Colors.white),
          Icon(Icons.confirmation_number, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
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
      case 1:
        return 'Vé Của Tôi';
      case 2:
        return 'Yêu Thích';
      case 3:
        return 'Tài Khoản';
      default:
        return 'Trang Chủ';
    }
  }
}
