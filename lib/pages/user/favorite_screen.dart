import 'package:flutter/material.dart';

class MyFavoriteScreen extends StatelessWidget {
  const MyFavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Favorite Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
