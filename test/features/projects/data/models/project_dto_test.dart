import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/features/projects/data/models/project_dto.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

// Fixtures below are copied verbatim (field-for-field) from
// assets/test_data.json entries 1 and 3, which is the actual shape exam
// seed data arrives in: integer id, display-label status/priority,
// yyyy-MM-dd date strings.
const _entry1Json = '''
{
"id": 1,
"clientName": "Acme Corporation",
"projectName": "Corporate Website Redesign",
"description": "Redesign and modernize the company's corporate website.",
"status": "In Progress",
"priority": "High",
"startDate": "2026-06-01",
"dueDate": "2026-07-15"
}
''';

const _entry3Json = '''
{
"id": 3,
"clientName": "Bright Realty",
"projectName": "Property Listing Portal",
"description": "Build a portal for managing property listings.",
"status": "On Hold",
"priority": "Medium",
"startDate": "2026-05-15",
"dueDate": "2026-07-30"
}
''';

void main() {
  group('ProjectDto.fromJson', () {
    test('parses an integer id as a String', () {
      final dto = ProjectDto.fromJson(jsonDecode(_entry1Json));

      expect(dto.id, '1');
    });

    test('parses clientName, projectName, and description verbatim', () {
      final dto = ProjectDto.fromJson(jsonDecode(_entry1Json));

      expect(dto.clientName, 'Acme Corporation');
      expect(dto.projectName, 'Corporate Website Redesign');
      expect(dto.description,
          "Redesign and modernize the company's corporate website.",);
    });

    test('parses status and priority display labels into enum values', () {
      final dto = ProjectDto.fromJson(jsonDecode(_entry1Json));

      expect(dto.status, ProjectStatus.inProgress);
      expect(dto.priority, ProjectPriority.high);
    });

    test('parses date-only strings into DateTime', () {
      final dto = ProjectDto.fromJson(jsonDecode(_entry1Json));

      expect(dto.startDate, DateTime.parse('2026-06-01'));
      expect(dto.dueDate, DateTime.parse('2026-07-15'));
    });

    test('parses a second entry with different status/priority labels', () {
      final dto = ProjectDto.fromJson(jsonDecode(_entry3Json));

      expect(dto.id, '3');
      expect(dto.status, ProjectStatus.onHold);
      expect(dto.priority, ProjectPriority.medium);
      expect(dto.startDate, DateTime.parse('2026-05-15'));
      expect(dto.dueDate, DateTime.parse('2026-07-30'));
    });

    test('propagates a clear error for an unrecognized status label', () {
      final json = jsonDecode(_entry1Json) as Map<String, dynamic>;
      json['status'] = 'Not A Real Status';

      expect(() => ProjectDto.fromJson(json), throwsA(isA<ArgumentError>()));
    });
  });

  group('ProjectDto.toEntity', () {
    test('maps every field onto a matching Project entity', () {
      final dto = ProjectDto(
        id: '1',
        clientName: 'Acme Corporation',
        projectName: 'Corporate Website Redesign',
        description: "Redesign and modernize the company's corporate website.",
        status: ProjectStatus.inProgress,
        priority: ProjectPriority.high,
        startDate: DateTime.parse('2026-06-01'),
        dueDate: DateTime.parse('2026-07-15'),
      );

      final entity = dto.toEntity();

      expect(
        entity,
        Project(
          id: dto.id,
          clientName: dto.clientName,
          projectName: dto.projectName,
          description: dto.description,
          status: dto.status,
          priority: dto.priority,
          startDate: dto.startDate,
          dueDate: dto.dueDate,
        ),
      );
    });
  });
}
