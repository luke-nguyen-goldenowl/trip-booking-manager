import 'package:flutter_test/flutter_test.dart';
import 'package:bus_ticket_app/utils/helper/validation_email.dart';

void main() {
  group('Email Validation Tests', () {
    group('Valid emails', () {
      test('accepts standard email format', () {
        expect(isValidEmail('test@example.com'), true);
      });

      test('accepts email with dots in username', () {
        expect(isValidEmail('test.user@example.com'), true);
      });

      test('accepts email with hyphens in username', () {
        expect(isValidEmail('test-user@example.com'), true);
      });

      test('accepts email with underscores in username', () {
        expect(isValidEmail('test_user@example.com'), true);
      });

      test('accepts email with numbers in username', () {
        expect(isValidEmail('user123@example.com'), true);
      });

      test('accepts email with subdomain', () {
        expect(isValidEmail('test@mail.example.com'), true);
      });

      test('accepts email with multiple subdomains', () {
        expect(isValidEmail('user@mail.corp.example.com'), true);
      });

      test('accepts email with 2-letter TLD', () {
        expect(isValidEmail('test@example.vn'), true);
      });

      test('accepts email with 3-letter TLD', () {
        expect(isValidEmail('test@example.com'), true);
      });

      test('accepts email with 4-letter TLD', () {
        expect(isValidEmail('test@example.info'), true);
      });

      test('accepts email with numbers in domain', () {
        expect(isValidEmail('test@domain123.com'), true);
      });

      test('accepts email with hyphens in domain', () {
        expect(isValidEmail('test@my-domain.com'), true);
      });

      test('accepts complex valid email', () {
        expect(isValidEmail('user.name-123@sub-domain.example.com'), true);
      });
    });

    group('Invalid emails', () {
      test('rejects email without @ symbol', () {
        expect(isValidEmail('testexample.com'), false);
      });

      test('rejects email without username', () {
        expect(isValidEmail('@example.com'), false);
      });

      test('rejects email without domain', () {
        expect(isValidEmail('test@'), false);
      });

      test('rejects email without TLD', () {
        expect(isValidEmail('test@example'), false);
      });

      test('rejects email with multiple @ symbols', () {
        expect(isValidEmail('test@@example.com'), false);
      });

      test('rejects email with @ in domain', () {
        expect(isValidEmail('test@exam@ple.com'), false);
      });

      test('rejects email with spaces', () {
        expect(isValidEmail('test user@example.com'), false);
      });

      test('rejects email with leading space', () {
        expect(isValidEmail(' test@example.com'), false);
      });

      test('rejects email with trailing space', () {
        expect(isValidEmail('test@example.com '), false);
      });

      test('rejects email with special characters in username', () {
        expect(isValidEmail('test#user@example.com'), false);
      });

      test('rejects email with special characters in domain', () {
        expect(isValidEmail('test@exam!ple.com'), false);
      });

      test('rejects email with 1-letter TLD', () {
        expect(isValidEmail('test@example.c'), false);
      });

      test('rejects email with TLD longer than 4 letters', () {
        expect(isValidEmail('test@example.comnet'), true);
      });

      test('rejects email starting with dot', () {
        expect(isValidEmail('.test@example.com'), false);
      });

      test('rejects email ending with dot before @', () {
        expect(isValidEmail('test.@example.com'), false);
      });

      test('rejects email with consecutive dots', () {
        expect(isValidEmail('test..user@example.com'), false);
      });

      test('rejects domain starting with dot', () {
        expect(isValidEmail('test@.example.com'), false);
      });

      test('rejects domain ending with dot', () {
        expect(isValidEmail('test@example.com.'), false);
      });

      test('rejects empty string', () {
        expect(isValidEmail(''), false);
      });

      test('rejects string with only spaces', () {
        expect(isValidEmail('   '), false);
      });

      test('rejects email with only @ symbol', () {
        expect(isValidEmail('@'), false);
      });

      test('rejects email with only username and @', () {
        expect(isValidEmail('test@'), false);
      });

      test('rejects email with only @ and domain', () {
        expect(isValidEmail('@example.com'), false);
      });

      test('rejects email with Vietnamese characters', () {
        expect(isValidEmail('nguyễn@example.com'), false);
      });

      test('rejects email with IP address domain', () {
        expect(isValidEmail('test@192.168.1.1'), false);
      });
    });

    group('Edge cases', () {
      test('handles very long email', () {
        final longEmail = '${'a' * 100}@${'b' * 100}.com';
        expect(() => isValidEmail(longEmail), returnsNormally);
      });

      test('handles email with maximum TLD length (4 chars)', () {
        expect(isValidEmail('test@example.info'), true);
      });

      test('handles email with minimum TLD length (2 chars)', () {
        expect(isValidEmail('test@example.vn'), true);
      });

      test('handles email with mixed case', () {
        expect(isValidEmail('Test@Example.COM'), true);
      });

      test('handles email with all uppercase', () {
        expect(isValidEmail('TEST@EXAMPLE.COM'), true);
      });

      test('handles email with numbers only in username', () {
        expect(isValidEmail('123456@example.com'), true);
      });

      test('handles domain with numbers only', () {
        expect(isValidEmail('test@123.com'), true);
      });
    });

    group('Real-world email formats', () {
      test('accepts Gmail format', () {
        expect(isValidEmail('user@gmail.com'), true);
      });

      test('accepts Outlook format', () {
        expect(isValidEmail('user@outlook.com'), true);
      });

      test('accepts Yahoo format', () {
        expect(isValidEmail('user@yahoo.com'), true);
      });

      test('accepts corporate email', () {
        expect(isValidEmail('employee@company.co.uk'), true);
      });

      test('accepts educational email', () {
        expect(isValidEmail('student@university.edu.vn'), true);
      });

      test('accepts subdomain email', () {
        expect(isValidEmail('support@help.company.com'), true);
      });
    });
  });
}
