import 'package:intl/intl.dart';

class FormatHelper {
  static String formatCurrency(double value) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(value)} VNĐ";
  }
}
