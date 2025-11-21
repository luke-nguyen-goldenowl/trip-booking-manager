import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/widgets/login_button.dart';
import 'package:bus_ticket_app/core/auth/login/login_service.dart';

class GetStartedV1 extends StatefulWidget {
  const GetStartedV1({super.key});

  static final List<SocialLoginOption> _socialLoginOptions = [
    SocialLoginOption(
      id: 'google',
      label: 'Đăng nhập với Google',
      icon: Image.asset(
        'assets/images/google.png',
        width: 24,
        height: 24,
        fit: BoxFit.cover,
      ),
    ),
  ];

  @override
  State<GetStartedV1> createState() => _GetStartedV1State();
}

class _GetStartedV1State extends State<GetStartedV1> {
  final _auth = LoginService();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/get_started_1.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withOpacity(0.3),
                    const Color(0xFF1B3B4A).withOpacity(0.8),
                    const Color(0xFF1B3B4A).withOpacity(0.95),
                  ],
                  stops: const <double>[0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage('assets/images/image.png'),
                        width: 40,
                        height: 40,
                      ),
                      const Text(
                        'GOBUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  const Text(
                    'Đặt vé xe nhanh chóng và tiện lợi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9200),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Bắt Đầu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'hoặc',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),

                  const SizedBox(height: 10.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        GetStartedV1._socialLoginOptions
                            .asMap()
                            .entries
                            .map<Widget>((entry) {
                              int index = entry.key;
                              SocialLoginOption option = entry.value;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: LoginIconButton(
                                    option: option,
                                    onPressed: () async {
                                      if (index == 0) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          await _signInWithGoogle();
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      } else if (index == 1) {
                                        //Facebook
                                      } else if (index == 2) {
                                        //Apple
                                      } else if (index == 3) {
                                        //Phone
                                      }
                                    },
                                  ),
                                ),
                              );
                            })
                            .toList(),
                  ),
                  const SizedBox(height: 20.0),
                  RichText(
                    text: TextSpan(
                      text: 'Bạn chưa có tài khoản? ',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Đăng Ký',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
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
}
