import 'package:bus_ticket_app/utils/helper/validation_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/core/auth/login/login_service.dart';
import 'package:flutter/services.dart';
import 'package:bus_ticket_app/utils/helper/lower_case_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = LoginService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00424B), Color(0xFF013E46)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Center(
                        child: Image(
                          image: AssetImage('assets/images/image.png'),
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Đăng Nhập',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Đăng nhập vào tài khoản của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Nhập địa chỉ email của bạn',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [LowerCaseTextFormatter()],
                        validator: (value) {
                          if (isValidEmail(value?.trim() ?? '')) {
                            return null;
                          } else {
                            return 'Vui lòng nhập địa chỉ email hợp lệ';
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Mật Khẩu',
                        hint: 'Nhập mật khẩu của bạn',
                        icon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.go('/forgot-password');
                            },
                            child: const Text(
                              'Quên Mật Khẩu?',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _loginWithFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(),
                                )
                                : Text(
                                  'Đăng Nhập',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: Container(height: 1, color: Colors.white30),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'hoặc',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: Colors.white30),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSocialButton(
                        'assets/images/google.png',
                        _signInWithGoogle,
                      ),
                      const SizedBox(height: 40),

                      RichText(
                        text: TextSpan(
                          text: 'Bạn chưa có tài khoản? ',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Đăng Ký',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go('/register');
                                    },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.transparent.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.white70),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image, size: 24, color: Colors.grey);
            },
          ),
          const SizedBox(width: 12),
          Text(
            'Đăng nhập với Google',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithFirebase() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final result = await _auth.loginWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isError) {
      if (result.error?.contains('chưa được xác nhận') == true) {
        _showEmailVerificationDialog(_emailController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Đã xảy ra lỗi không xác định'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final user = result.data!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chào mừng ${user.fullName ?? user.email}!'),
        backgroundColor: Colors.green,
      ),
    );
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _auth.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Đăng nhập Google thất bại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = result.data!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chào mừng ${user.fullName ?? user.email}!'),
        backgroundColor: Colors.green,
      ),
    );
    if (mounted) {
      context.go('/');
    }
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Colors.orange),
              SizedBox(width: 10),
              Text('Xác nhận Email'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email của bạn chưa được xác nhận.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Vui lòng kiểm tra hộp thư của bạn tại:\n$email',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nếu bạn chưa nhận được email, hãy nhấn nút bên dưới để gửi lại.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resendVerificationEmail(email);
              },
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Gửi lại Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resendVerificationEmail(String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _auth.resendVerificationEmail(
      email,
      _passwordController.text,
    );

    Navigator.of(context).pop();

    if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email xác nhận đã được gửi! Vui lòng kiểm tra hộp thư.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
