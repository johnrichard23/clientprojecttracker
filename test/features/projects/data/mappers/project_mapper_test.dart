import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/features/projects/data/mappers/project_mapper.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

void main() {
  group('ProjectMapper row <-> entity round trip', () {
    test('maps a row to an entity with matching fields', () {
      final row = ProjectsTableData(
        id: 'abc-123',
        clientName: 'Acme Corp',
        projectName: 'Website Revamp',
        description: 'Full redesign of the marketing site.',
        status: ProjectStatus.inProgress.name,
        priority: ProjectPriority.high.name,
        startDate: DateTime(2026, 7, 1),
        dueDate: DateTime(2026, 8, 1),
      );

      final entity = row.toEntity();

      expect(entity.id, row.id);
      expect(entity.clientName, row.clientName);
      expect(entity.projectName, row.projectName);
      expect(entity.description, row.description);
      expect(entity.status, ProjectStatus.inProgress);
      expect(entity.priority, ProjectPriority.high);
      expect(entity.startDate, row.startDate);
      expect(entity.dueDate, row.dueDate);
    });

    test('round-trips row -> entity -> companion without losing data', () {
      final row = ProjectsTableData(
        id: 'xyz-789',
        clientName: 'Globex',
        projectName: 'Mobile App',
        description: '',
        status: ProjectStatus.cancelled.name,
        priority: ProjectPriority.medium.name,
        startDate: DateTime(2026, 1, 15),
        dueDate: DateTime(2026, 3, 15),
      );

      final entity = row.toEntity();
      final companion = entity.toCompanion();

      expect(companion.id.value, row.id);
      expect(companion.clientName.value, row.clientName);
      expect(companion.projectName.value, row.projectName);
      expect(companion.description.value, row.description);
      expect(companion.status.value, row.status);
      expect(companion.priority.value, row.priority);
      expect(companion.startDate.value, row.startDate);
      expect(companion.dueDate.value, row.dueDate);
    });

    test('every ProjectStatus value serializes to text and back', () {
      for (final status in ProjectStatus.values) {
        final row = ProjectsTableData(
          id: 'id',
          clientName: 'Client',
          projectName: 'Project',
          description: '',
          status: status.name,
          priority: ProjectPriority.medium.name,
          startDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 1, 2),
        );

        expect(row.toEntity().status, status);
      }
    });

    test('every ProjectPriority value serializes to text and back', () {
      for (final priority in ProjectPriority.values) {
        final row = ProjectsTableData(
          id: 'id',
          clientName: 'Client',
          projectName: 'Project',
          description: '',
          status: ProjectStatus.planning.name,
          priority: priority.name,
          startDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 1, 2),
        );

        expect(row.toEntity().priority, priority);
      }
    });

    test('every ProjectStatus value on an entity serializes to matching text', () {
      for (final status in ProjectStatus.values) {
        final entity = Project(
          id: 'id',
          clientName: 'Client',
          projectName: 'Project',
          description: '',
          status: status,
          priority: ProjectPriority.medium,
          startDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 1, 2),
        );

        expect(entity.toCompanion().status.value, status.name);
      }
    });

    test('every ProjectPriority value on an entity serializes to matching text', () {
      for (final priority in ProjectPriority.values) {
        final entity = Project(
          id: 'id',
          clientName: 'Client',
          projectName: 'Project',
          description: '',
          status: ProjectStatus.planning,
          priority: priority,
          startDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 1, 2),
        );

        expect(entity.toCompanion().priority.value, priority.name);
      }
    });
  });
}
