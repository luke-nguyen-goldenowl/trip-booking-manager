import 'package:bus_ticket_app/pages/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'config/db/supabase.dart';
import 'package:bus_ticket_app/routes/route.dart';
import 'package:bus_ticket_app/pages/get_started/get_started_1.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/models/MUser.dart' as user_model;
import 'package:bus_ticket_app/pages/user/home.dart';
import 'package:bus_ticket_app/pages/admin/home.dart';
import 'package:bus_ticket_app/pages/bus_company/home.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/bus_service.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/bus_route_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit(UserService())),
        BlocProvider(create: (context) => BusCubit(BusService())),
        BlocProvider(create: (context) => BusRouteCubit(BusRouteService())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bus Ticket App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00424B)),
        ),
        routerConfig: router,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final User firebaseUser = snapshot.data!;
          return FutureBuilder<user_model.MUser?>(
            future: UserService().getUserInfo(firebaseUser.email!),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userSnapshot.hasError) {
                FirebaseAuth.instance.signOut();
              }
              if (userSnapshot.hasData && userSnapshot.data != null) {
                final user_model.MUser user = userSnapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<UserCubit>().loadUser(firebaseUser.email!);
                });

                return _getHomeScreenByRole(user.role ?? 'Khách hàng');
              }
              FirebaseAuth.instance.signOut();
              return const GetStartedV1();
            },
          );
        }
        return const SplashScreen();
      },
    );
  }

  Widget _getHomeScreenByRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const HomeAdminScreen();
      case 'nhà xe':
        return const HomeBusCompanyScreen();
      case 'khách hàng':
      default:
        return const HomeUserScreen();
    }
  }
}
