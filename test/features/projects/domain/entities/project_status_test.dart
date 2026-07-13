import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

void main() {
  group('ProjectStatus.fromLabel', () {
    test('returns the matching enum value for every valid label', () {
      expect(ProjectStatus.fromLabel('Planning'), ProjectStatus.planning);
      expect(ProjectStatus.fromLabel('In Progress'), ProjectStatus.inProgress);
      expect(ProjectStatus.fromLabel('On Hold'), ProjectStatus.onHold);
      expect(ProjectStatus.fromLabel('Completed'), ProjectStatus.completed);
      expect(ProjectStatus.fromLabel('Cancelled'), ProjectStatus.cancelled);
    });

    test('throws an ArgumentError with a clear message for an unrecognized label', () {
      expect(
        () => ProjectStatus.fromLabel('Not A Real Status'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message.toString(),
          'message',
          contains('Not A Real Status'),
        )),
      );
    });
  });
}
