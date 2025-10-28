import 'package:bus_ticket_app/models/user_model.dart';

class RouteHelper {
  static String getHomeRouteByRole(MUser user) {
    switch (user.role?.toLowerCase()) {
      case 'admin':
        return '/home-admin';
      case 'nhà xe':
        return '/home-bus-company';
      case 'khách hàng':
      default:
        return '/home-user';
    }
  }

  static String getHomeRouteName(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Admin Dashboard';
      case 'nhà xe':
        return 'Nhà Xe Dashboard';
      case 'khách hàng':
      default:
        return 'Trang Chủ';
    }
  }
}
