import 'package:intl/intl.dart';

class FormatHelper {
  static String formatCurrency(double value) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(value)} VNĐ";
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('HH:mm').format(dateTime);
  }
}
