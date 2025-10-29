import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final smtpServer = gmail(
  dotenv.env['GMAIL_MAIL']!,
  dotenv.env['GMAIL_PASSWORD']!,
);
