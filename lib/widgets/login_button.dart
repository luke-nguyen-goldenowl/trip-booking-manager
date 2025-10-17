import 'package:flutter/material.dart';

class SocialLoginOption {
  final String id;
  final String label;
  final Widget icon;

  const SocialLoginOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class LoginIconButton extends StatelessWidget {
  final SocialLoginOption option;
  final VoidCallback onPressed;

  const LoginIconButton({
    super.key,
    required this.option,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: option.icon,
    );
  }
}
