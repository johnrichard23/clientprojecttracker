import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

/// Wire format for the exam seed data (assets/test_data.json). Its shape
/// doesn't match the internal Model: `id` is an integer, `status`/`priority`
/// are display labels rather than enum names. `fromJson` normalizes those
/// into the same types the rest of the app uses - see
/// docs/constitution.md, Section 5 (DTO/Entity/Model Contract).
class ProjectDto {
  final String id;
  final String clientName;
  final String projectName;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime startDate;
  final DateTime dueDate;

  const ProjectDto({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'].toString(),
      clientName: json['clientName'] as String,
      projectName: json['projectName'] as String,
      description: json['description'] as String,
      status: ProjectStatus.fromLabel(json['status'] as String),
      priority: ProjectPriority.fromLabel(json['priority'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
    );
  }
}

extension ProjectDtoMapper on ProjectDto {
  Project toEntity() {
    return Project(
      id: id,
      clientName: clientName,
      projectName: projectName,
      description: description,
      status: status,
      priority: priority,
      startDate: startDate,
      dueDate: dueDate,
    );
  }
}
