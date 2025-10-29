import 'package:flutter/material.dart';
import 'package:bus_ticket_app/pages/user/home_screen.dart';
import 'package:bus_ticket_app/pages/user/bottom_navigation.dart';

class HomeUserScreen extends StatelessWidget {
  const HomeUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: MainScaffold(child: HomeScreen())));
  }
}
