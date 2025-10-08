// test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validator', () {
      test('should return null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co.uk'), isNull);
      });

      test('should return error for invalid email', () {
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@example.com'), isNotNull);
        expect(Validators.email('test@.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });
    });

    group('Password Validator', () {
      test('should return null for valid password', () {
        expect(Validators.password('password123'), isNull);
        expect(Validators.password('abc123'), isNull);
      });

      test('should return error for short password', () {
        expect(Validators.password('abc', minLength: 6), isNotNull);
        expect(Validators.password('12345', minLength: 6), isNotNull);
      });

      test('should return error for empty password', () {
        expect(Validators.password(''), isNotNull);
        expect(Validators.password(null), isNotNull);
      });
    });

    group('Required Validator', () {
      test('should return null for non-empty value', () {
        expect(Validators.required('some value'), isNull);
      });

      test('should return error for empty value', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required(null), isNotNull);
        expect(Validators.required('   '), isNotNull);
      });
    });

    group('Number Validator', () {
      test('should return null for valid number', () {
        expect(Validators.number('123'), isNull);
        expect(Validators.number('123.45'), isNull);
        expect(Validators.number('-10'), isNull);
      });

      test('should return error for invalid number', () {
        expect(Validators.number('abc'), isNotNull);
        expect(Validators.number('12a3'), isNotNull);
      });
    });

    group('Phone Validator', () {
      test('should return null for valid Lao phone number', () {
        expect(Validators.phone('20 1234 5678'), isNull);
        expect(Validators.phone('2012345678'), isNull);
        expect(Validators.phone('030 1234 567'), isNull);
      });

      test('should return error for invalid phone number', () {
        expect(Validators.phone('123456'), isNotNull);
        expect(Validators.phone('9999999999'), isNotNull);
      });
    });

    group('Confirm Password Validator', () {
      test('should return null when passwords match', () {
        expect(Validators.confirmPassword('password', 'password'), isNull);
      });

      test('should return error when passwords do not match', () {
        expect(Validators.confirmPassword('password', 'different'), isNotNull);
      });
    });
  });
}
