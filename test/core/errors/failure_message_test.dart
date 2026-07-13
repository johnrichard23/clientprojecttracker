import 'package:flutter_test/flutter_test.dart';

import 'package:client_project_tracker/core/errors/failure_message.dart';
import 'package:client_project_tracker/core/errors/failures.dart';

void main() {
  group('Failure.toUserMessage', () {
    test('ValidationFailure produces a short, user-readable message', () {
      final failure = ValidationFailure(
        'clientName: required, dueDate: must be >= startDate',
        fieldErrors: {'clientName': 'Client name is required.'},
      );

      final message = failure.toUserMessage();

      expect(message, isNotEmpty);
      expect(message, isNot(contains(failure.message)));
      expect(message.toLowerCase(), isNot(contains('failure')));
    });

    test('DatabaseFailure produces a short, user-readable message', () {
      final failure = DatabaseFailure(
        'Failed to load projects: SqliteException(1): no such table: projects',
      );

      final message = failure.toUserMessage();

      expect(message, isNotEmpty);
      expect(message, isNot(contains(failure.message)));
      expect(message, isNot(contains('SqliteException')));
      expect(message.toLowerCase(), isNot(contains('failure')));
    });

    test('NetworkFailure produces a short, user-readable message', () {
      final failure = NetworkFailure('SocketException: Connection refused');

      final message = failure.toUserMessage();

      expect(message, isNotEmpty);
      expect(message, isNot(contains(failure.message)));
      expect(message, isNot(contains('SocketException')));
      expect(message.toLowerCase(), isNot(contains('failure')));
    });

    test('NotFoundFailure produces a short, user-readable message', () {
      final failure = NotFoundFailure('No project found with id "abc-123".');

      final message = failure.toUserMessage();

      expect(message, isNotEmpty);
      expect(message, isNot(contains(failure.message)));
      expect(message, isNot(contains('abc-123')));
      expect(message.toLowerCase(), isNot(contains('failure')));
    });

    test('UnknownFailure produces a short, user-readable message', () {
      final failure = UnknownFailure('Unhandled exception: null check operator');

      final message = failure.toUserMessage();

      expect(message, isNotEmpty);
      expect(message, isNot(contains(failure.message)));
      expect(message.toLowerCase(), isNot(contains('failure')));
    });
  });
}
