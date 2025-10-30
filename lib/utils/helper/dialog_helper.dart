import 'package:flutter/material.dart';
import 'package:bus_ticket_app/widgets/confirmation_dialog.dart';

class DialogHelper {
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
    String? itemType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ConfirmationDialog(
          title: 'Xóa ${itemType ?? 'mục'}',
          message:
              'Bạn có chắc chắn muốn xóa $itemName?\n\nHành động này không thể hoàn tác.',
          confirmText: 'Xóa',
          cancelText: 'Hủy',
          isDangerous: true,
          icon: Icons.delete_outline,
        );
      },
    );
    return result ?? false;
  }

  static Future<bool> showCancelledConfirmation(
    BuildContext context, {
    required String itemName,
    String? itemType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ConfirmationDialog(
          title: 'Huỷ ${itemType ?? 'vé'}',
          message:
              'Bạn có chắc chắn muốn huỷ vé $itemName?\n\nHành động này không thể hoàn tác.',
          confirmText: 'Huỷ',
          cancelText: 'Đóng',
          isDangerous: true,
          icon: Icons.delete_outline,
        );
      },
    );
    return result ?? false;
  }

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    IconData? icon,
    Color? iconColor,
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          icon: icon,
          iconColor: iconColor,
          confirmColor: confirmColor,
          isDangerous: isDangerous,
        );
      },
    );
    return result ?? false;
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Đóng',
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }
}
