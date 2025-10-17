import 'package:flutter/material.dart';

class BusTripScreen extends StatelessWidget {
  const BusTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Bus Company Trips',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
