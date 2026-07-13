import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

/// The core business object for a client project.
///
/// This is pure Dart - no serialization, no persistence annotations, no
/// Flutter imports. See docs/constitution.md, Section 5 (DTO/Entity/Model
/// Contract) for why this stays separate from the data-layer Model/DTO.
class Project {
  final String id;
  final String clientName;
  final String projectName;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime startDate;
  final DateTime dueDate;

  const Project({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
  });

  Project copyWith({
    String? clientName,
    String? projectName,
    String? description,
    ProjectStatus? status,
    ProjectPriority? priority,
    DateTime? startDate,
    DateTime? dueDate,
  }) {
    return Project(
      id: id,
      clientName: clientName ?? this.clientName,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientName == other.clientName &&
          projectName == other.projectName &&
          description == other.description &&
          status == other.status &&
          priority == other.priority &&
          startDate == other.startDate &&
          dueDate == other.dueDate;

  @override
  int get hashCode => Object.hash(
        id,
        clientName,
        projectName,
        description,
        status,
        priority,
        startDate,
        dueDate,
      );
}
