import 'package:fpdart/fpdart.dart';

import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/validators/project_validator.dart';

/// Field values for an existing project being edited.
class UpdateProjectParams {
  final String id;
  final String clientName;
  final String projectName;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime startDate;
  final DateTime dueDate;

  const UpdateProjectParams({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
  });
}

/// Validates input, then delegates the update to the repository, preserving
/// the existing project's id. See docs/architecture.md, Section 6.
class UpdateProject {
  final ProjectRepository _repository;
  final ProjectValidator _validator;

  UpdateProject(this._repository, {ProjectValidator? validator})
      : _validator = validator ?? ProjectValidator();

  Future<Either<Failure, Project>> call(UpdateProjectParams params) async {
    final validation = _validator.validate(
      clientName: params.clientName,
      projectName: params.projectName,
      description: params.description,
      startDate: params.startDate,
      dueDate: params.dueDate,
    );

    if (!validation.isValid) {
      return Left(ValidationFailure(
        'Please fix the highlighted fields.',
        fieldErrors: validation.fieldErrors,
      ),);
    }

    final project = Project(
      id: params.id,
      clientName: params.clientName,
      projectName: params.projectName,
      description: params.description,
      status: params.status,
      priority: params.priority,
      startDate: params.startDate,
      dueDate: params.dueDate,
    );

    return _repository.updateProject(project);
  }
}
