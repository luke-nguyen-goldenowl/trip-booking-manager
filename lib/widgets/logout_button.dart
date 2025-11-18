import 'package:bus_ticket_app/core/auth/logout/log_out_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class LogoutButton extends StatelessWidget {
  LogOutService logOutService = LogOutService();
  LogoutButton({super.key});

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
            await logOutService.logout();
            if (context.mounted) {
              context.go('/getstarted');
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
