import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int index = 0;
    if (location.startsWith('/tickets')) index = 1;
    if (location.startsWith('/favorite')) index = 2;
    if (location.startsWith('/profile')) index = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xFF004049),
        buttonBackgroundColor: const Color(0xFF004049),
        height: 60,
        index: index,
        items: const [
          Icon(Icons.home, size: 25, color: Colors.white),
          Icon(Icons.confirmation_number, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
          Icon(Icons.person, size: 25, color: Colors.white),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/tickets');
              break;
            case 2:
              context.go('/favorite');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
