import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';

void main() {
  group('ProjectPriority.fromLabel', () {
    test('returns the matching enum value for every valid label', () {
      expect(ProjectPriority.fromLabel('Low'), ProjectPriority.low);
      expect(ProjectPriority.fromLabel('Medium'), ProjectPriority.medium);
      expect(ProjectPriority.fromLabel('High'), ProjectPriority.high);
    });

    test('throws an ArgumentError with a clear message for an unrecognized label', () {
      expect(
        () => ProjectPriority.fromLabel('Not A Real Priority'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message.toString(),
          'message',
          contains('Not A Real Priority'),
        ),),
      );
    });
  });
}
