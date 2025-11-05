import 'dart:io';
import 'package:bus_ticket_app/core/booking/cubit/booking_cubit.dart';
import 'package:bus_ticket_app/core/company/cubit/company_cubit.dart';
import 'package:bus_ticket_app/core/network/cubit/internet_connection_cubit.dart';
import 'package:bus_ticket_app/core/network/internet_connection_listener.dart';
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
import 'package:bus_ticket_app/models/user_model.dart' as user_model;
import 'package:bus_ticket_app/pages/user/home.dart';
import 'package:bus_ticket_app/pages/admin/home.dart';
import 'package:bus_ticket_app/pages/bus_company/home.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_cubit.dart';
import 'package:bus_ticket_app/core/bus/bus_service.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_cubit.dart';
import 'package:bus_ticket_app/core/bus_route/bus_route_service.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_cubit.dart';
import 'package:bus_ticket_app/core/bus_trip/bus_trip_service.dart';
import 'package:bus_ticket_app/core/booking/booking_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeSupabase();
  await initializeDateFormatting('vi', null);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit(UserService())),
        BlocProvider(create: (context) => CompanyCubit(UserService())),
        BlocProvider(create: (context) => BusCubit(BusService())),
        BlocProvider(create: (context) => BusRouteCubit(BusRouteService())),
        BlocProvider(create: (context) => BusTripCubit(BusTripService())),
        BlocProvider(create: (context) => BookingCubit(BookingService())),
        BlocProvider(create: (context) => InternetConnectionCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bus Ticket App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00424B)),
        ),
        locale: const Locale('vi', 'VN'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
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
    Widget screen;
    switch (role.toLowerCase()) {
      case 'admin':
        screen = const HomeAdminScreen();
        break;
      case 'nhà xe':
        screen = const HomeBusCompanyScreen();
        break;
      case 'khách hàng':
      default:
        screen = const HomeUserScreen();
    }
    return InternetListener(child: screen);
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
