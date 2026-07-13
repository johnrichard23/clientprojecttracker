import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/features/projects/domain/validators/project_validator.dart';

void main() {
  late ProjectValidator validator;

  setUp(() {
    validator = ProjectValidator();
  });

  group('ProjectValidator.validate', () {
    test('returns no errors for a fully valid draft', () {
      final result = validator.validate(
        clientName: 'Acme Corp',
        projectName: 'Website Revamp',
        description: 'Full redesign of the marketing site.',
        startDate: DateTime(2026, 7, 1),
        dueDate: DateTime(2026, 8, 1),
      );

      expect(result.isValid, isTrue);
      expect(result.fieldErrors, isEmpty);
    });

    test('flags a missing client name', () {
      final result = validator.validate(
        clientName: '',
        projectName: 'Website Revamp',
        description: '',
        startDate: DateTime(2026, 7, 1),
        dueDate: DateTime(2026, 8, 1),
      );

      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('clientName'), isTrue);
    });

    test('flags a missing project name', () {
      final result = validator.validate(
        clientName: 'Acme Corp',
        projectName: '   ',
        description: '',
        startDate: DateTime(2026, 7, 1),
        dueDate: DateTime(2026, 8, 1),
      );

      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('projectName'), isTrue);
    });

    test('flags a due date before the start date', () {
      final result = validator.validate(
        clientName: 'Acme Corp',
        projectName: 'Website Revamp',
        description: '',
        startDate: DateTime(2026, 8, 1),
        dueDate: DateTime(2026, 7, 1),
      );

      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('dueDate'), isTrue);
    });

    test('allows the due date to equal the start date', () {
      final result = validator.validate(
        clientName: 'Acme Corp',
        projectName: 'Website Revamp',
        description: '',
        startDate: DateTime(2026, 8, 1),
        dueDate: DateTime(2026, 8, 1),
      );

      expect(result.isValid, isTrue);
    });

    test('flags a description over 2000 characters', () {
      final result = validator.validate(
        clientName: 'Acme Corp',
        projectName: 'Website Revamp',
        description: 'a' * 2001,
        startDate: DateTime(2026, 7, 1),
        dueDate: DateTime(2026, 8, 1),
      );

      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('description'), isTrue);
    });

    test('reports multiple field errors at once', () {
      final result = validator.validate(
        clientName: '',
        projectName: '',
        description: '',
        startDate: DateTime(2026, 8, 1),
        dueDate: DateTime(2026, 7, 1),
      );

      expect(result.fieldErrors.length, 3);
    });
  });
}
