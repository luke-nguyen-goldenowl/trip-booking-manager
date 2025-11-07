import 'package:mailer/mailer.dart';
import 'package:bus_ticket_app/config/email/email_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendHtmlMail(
  String toEmail,
  String subject,
  String htmlBody, {
  String? plainTextFallback,
}) async {
  final message =
      Message()
        ..from = Address(dotenv.env['GMAIL_MAIL']!, 'GO BUS')
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = htmlBody;

  if (plainTextFallback != null) {
    message.text = plainTextFallback;
  }

  try {
    await send(message, smtpServer);
  } on MailerException catch (e) {
    throw Exception('Không thể gửi email: $e');
  }
}

Future<void> sendBookingConfirmationEmail({
  required String toEmail,
  required String userName,
  required String bookingCode,
  required String departure,
  required String destination,
  required String departureTime,
  required String seats,
  required int totalPrice,
  String? createdAt,
  String? companyLogo,
  String? companyName,
  String? companyPhone,
  String? licensePlate,
  String? paymentMethod,
}) async {
  final htmlBody = '''
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
      <tr>
        <td align="center">
          <table width="600" cellpadding="0" cellspacing="0" style="background-color: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            
            <!-- Header -->
            <tr>
              <td style="background: linear-gradient(135deg, #007BFF 0%, #0056b3 100%); padding: 40px 30px; text-align: center;">
                <h1 style="color: white; margin: 0; font-size: 28px;">🎟️ XÁC NHẬN ĐẶT VÉ</h1>
                <p style="color: white; margin: 10px 0 0 0; font-size: 16px;">Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi!</p>
              </td>
            </tr>
            
            <!-- Content -->
            <tr>
              <td style="padding: 30px;">
                <p style="font-size: 16px; color: #333; margin: 0 0 20px 0;">
                  Xin chào <strong style="color: #007BFF;">$userName</strong>,
                </p>
                <p style="font-size: 14px; color: #666; margin: 0 0 20px 0;">
                  Đặt vé của bạn đã được xác nhận thành công. Dưới đây là thông tin chi tiết:
                </p>
                
                <!-- Info Box -->
                <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f8f9fa; border-radius: 8px; margin: 20px 0;">
                  <tr>
                    <td style="padding: 20px;">
                      <h3 style="margin: 0 0 15px 0; color: #007BFF; font-size: 18px;">Thông tin chuyến đi</h3>
                      
                      <table width="100%" cellpadding="8" cellspacing="0">
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Mã đặt vé:</td>
                          <td style="text-align: right; color: #007BFF; font-weight: bold; font-size: 16px;">$bookingCode</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Thời gian đặt vé:</td>
                          <td style="text-align: right; color: #333;">$createdAt</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Tuyến đường:</td>
                          <td style="text-align: right; color: #333;">$departure → $destination</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Khởi hành:</td>
                          <td style="text-align: right; color: #333;">$departureTime</td>
                        </tr>
                        ${licensePlate != null ? '''
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Biển số xe:</td>
                          <td style="text-align: right; color: #333;">$licensePlate</td>
                        </tr>
                        ''' : ''}
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Số ghế:</td>
                          <td style="text-align: right; color: #333;">$seats</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e0e0e0;">
                          <td style="color: #666; font-weight: bold;">Phương thức thanh toán:</td>
                          <td style="text-align: right; color: #333;">$paymentMethod</td>
                        </tr>
                        <tr>
                          <td style="color: #666; font-weight: bold; font-size: 18px;">Tổng tiền:</td>
                          <td style="text-align: right; color: #007BFF; font-weight: bold; font-size: 20px;">${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}₫</td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
                
                ${companyName != null ? '''
    <!-- Company Info -->
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #e8f5e9; border-radius: 8px; margin: 20px 0;">
      <tr>
        <td style="padding: 20px;">
          <h3 style="margin: 0 0 15px 0; color: #28a745; font-size: 18px;">🏢 Thông tin nhà xe</h3>
          
          <!-- ✅ Logo và thông tin nhà xe -->
          <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
              ${companyLogo != null ? '''
              <!-- Logo bên trái -->
              <td style="width: 80px; vertical-align: top;">
                <img src="$companyLogo" 
                     alt="Logo $companyName" 
                     width="60" 
                     height="60" 
                     style="border-radius: 50%; object-fit: cover; border: 2px solid #28a745;" />
              </td>
              ''' : ''}
              
              <!-- Thông tin bên phải -->
              <td style="vertical-align: middle; padding-left: ${companyLogo != null ? '15px' : '0'};">
                <p style="margin: 0 0 8px 0; color: #333; font-weight: bold; font-size: 16px;">$companyName</p>
                ${companyPhone != null ? '<p style="margin: 0; color: #666; font-size: 14px;">📞 $companyPhone</p>' : ''}
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    ''' : ''}
                
                <!-- Important Notice -->
                <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #fff3cd; border-radius: 8px; border-left: 4px solid #ffc107; margin: 20px 0;">
                  <tr>
                    <td style="padding: 15px;">
                      <p style="margin: 0; color: #856404; font-size: 14px;">
                        ⚠️ Vui lòng mang theo <strong>mã đặt vé $bookingCode</strong> và <strong>CMND/CCCD</strong> khi lên xe.
                      </p>
                    </td>
                  </tr>
                </table>
                
                <p style="font-size: 14px; color: #666; margin: 20px 0 0 0;">
                  Chúc bạn có một chuyến đi an toàn và vui vẻ! 🚌
                </p>
              </td>
            </tr>
            
            <!-- Footer -->
            <tr>
              <td style="background-color: #f8f9fa; padding: 20px; text-align: center; border-top: 1px solid #e0e0e0;">
                <p style="margin: 0; color: #999; font-size: 12px;">
                  Email này được gửi tự động, vui lòng không trả lời.
                </p>
                <p style="margin: 5px 0 0 0; color: #999; font-size: 12px;">
                  © 2025 Bus Ticket App. All rights reserved.
                </p>
              </td>
            </tr>
            
          </table>
        </td>
      </tr>
    </table>
  </body>
  </html>
  ''';

  final plainText = '''
Xác nhận đặt vé thành công

Xin chào $userName,

Mã đặt vé: $bookingCode
Tuyến: $departure → $destination
Thời gian khởi hành: $departureTime
${licensePlate != null ? 'Biển số xe: $licensePlate\n' : ''}Số ghế: $seats
Tổng tiền: ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}₫

${companyName != null ? 'Nhà xe: $companyName${companyPhone != null ? '\nSĐT: $companyPhone' : ''}\n' : ''}
Vui lòng mang theo mã đặt vé và CMND/CCCD khi lên xe.

Chúc bạn có chuyến đi vui vẻ!

---
Email này được gửi tự động, vui lòng không trả lời.
  ''';

  await sendHtmlMail(
    toEmail,
    'XÁC NHẬN ĐẶT VÉ',
    htmlBody,
    plainTextFallback: plainText,
  );
}
