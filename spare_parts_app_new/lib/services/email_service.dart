import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:spare_parts_app/config/email_config.dart';

class EmailService {
  final String _username = EmailConfig.username;
  final String _password = EmailConfig.password;

  Future<void> sendOtp(String recipientEmail, String otp) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'Spare Parts App')
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP for Spare Parts App'
      ..text = 'Your OTP is $otp';

    try {
      if (kDebugMode) {
        debugPrint('EmailService: Sending OTP email to $recipientEmail...');
      }
      final sendReport =
          await send(message, smtpServer).timeout(const Duration(seconds: 30));
      if (kDebugMode) {
        debugPrint('OTP email sent successfully: $sendReport');
      }
    } on MailerException catch (e) {
      if (kDebugMode) {
        debugPrint('OTP email failed to send (MailerException): $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OTP email failed to send (General Exception): $e');
      }
      rethrow;
    }
  }
}
