import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
          );

          if (shouldLogout == true) {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              context.go('/');
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
