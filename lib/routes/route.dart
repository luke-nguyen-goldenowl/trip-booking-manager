import 'package:bus_ticket_app/pages/splash_screen/splash_screen.dart';
import 'package:bus_ticket_app/pages/get_started/get_started_1.dart';
import 'package:bus_ticket_app/pages/on_boarding/onboarding_screen.dart';
import 'package:bus_ticket_app/pages/auth/login_screen.dart';
import 'package:bus_ticket_app/pages/auth/register_screen.dart';
import 'package:bus_ticket_app/pages/auth/forgot_password_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:bus_ticket_app/pages/user/home.dart';
import 'package:bus_ticket_app/pages/admin/home.dart';
import 'package:bus_ticket_app/pages/bus_company/home.dart';
import 'package:bus_ticket_app/main.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_car/bus_car_add_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_car/bus_car_edit_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_car/bus_car_detail_screen.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_route/bus_route_add_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_route/bus_route_detail_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_route/bus_route_edit_screen.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_trip/bus_trip_add_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_trip/bus_trip_detail_screen.dart';
import 'package:bus_ticket_app/pages/bus_company/bus_trip/bus_trip_edit_screen.dart';
import 'package:bus_ticket_app/pages/user/trip_search_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthWrapper()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/getstarted',
      builder: (context, state) => const GetStartedV1(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home-user',
      builder: (context, state) => const HomeUserScreen(),
    ),
    GoRoute(
      path: '/home-admin',
      builder: (context, state) => const HomeAdminScreen(),
    ),
    GoRoute(
      path: '/home-bus-company',
      builder: (context, state) => const HomeBusCompanyScreen(),
    ),
    GoRoute(
      path: '/home-bus-company/bus-car-add',
      builder: (context, state) => const BusCarAddScreen(),
    ),
    GoRoute(
      path: '/home-bus-company/bus-car-edit',
      builder: (context, state) {
        final bus = state.extra as MBus;
        return BusCarEditScreen(bus: bus);
      },
    ),
    GoRoute(
      path: '/home-bus-company/bus-car-detail',
      builder: (context, state) {
        final bus = state.extra as MBus;
        return BusCarDetailScreen(bus: bus);
      },
    ),
    GoRoute(
      path: '/home-bus-company/bus-route-add',
      builder: (context, state) => const BusRouteAddScreen(),
    ),
    GoRoute(
      path: '/home-bus-company/bus-route-detail',
      builder: (context, state) {
        final route = state.extra as MRoute;
        return BusRouteDetailScreen(route: route);
      },
    ),
    GoRoute(
      path: '/home-bus-company/bus-route-edit',
      builder: (context, state) {
        final route = state.extra as MRoute;
        return BusRouteEditScreen(route: route);
      },
    ),
    GoRoute(
      path: '/home-bus-company/bus-trip-add',
      builder: (context, state) => const BusTripAddScreen(),
    ),
    GoRoute(
      path: '/home-bus-company/bus-trip-detail',
      builder: (context, state) {
        final trip = state.extra as MTrip;
        return BusTripDetailScreen(trip: trip);
      },
    ),
    GoRoute(
      path: '/home-bus-company/bus-trip-edit',
      builder: (context, state) {
        final trip = state.extra as MTrip;
        return BusTripEditScreen(trip: trip);
      },
    ),
    GoRoute(
      path: '/user/trip-search',
      builder: (context, state) {
        final searchParams = state.extra as Map<String, dynamic>;
        return TripSearchScreen(searchParams: searchParams);
      },
    ),
  ],
);
