import 'package:drift/drift.dart';

import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

/// Row <-> Entity mapping (docs/architecture.md, Section 3;
/// docs/constitution.md, Section 5). Status/priority are stored as their
/// enum `.name` text in the DB and parsed back via `.values.byName`.
extension ProjectRowMapper on ProjectsTableData {
  Project toEntity() {
    return Project(
      id: id,
      clientName: clientName,
      projectName: projectName,
      description: description,
      status: ProjectStatus.values.byName(status),
      priority: ProjectPriority.values.byName(priority),
      startDate: startDate,
      dueDate: dueDate,
    );
  }
}

extension ProjectEntityMapper on Project {
  ProjectsTableCompanion toCompanion() {
    return ProjectsTableCompanion.insert(
      id: id,
      clientName: clientName,
      projectName: projectName,
      description: Value(description),
      status: status.name,
      priority: priority.name,
      startDate: startDate,
      dueDate: dueDate,
    );
  }
}
