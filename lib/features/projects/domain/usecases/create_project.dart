import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/validators/project_validator.dart';

/// Field values for a new project, before an id has been assigned.
class CreateProjectParams {
  final String clientName;
  final String projectName;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime startDate;
  final DateTime dueDate;

  const CreateProjectParams({
    required this.clientName,
    required this.projectName,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
  });
}

/// Validates input, generates the new project's id, and delegates creation
/// to the repository. See docs/architecture.md, Section 6 (Data Flow
/// Example) - validation runs before any repository call is made.
class CreateProject {
  final ProjectRepository _repository;
  final ProjectValidator _validator;
  final Uuid _uuid;

  CreateProject(this._repository, {ProjectValidator? validator, Uuid? uuid})
      : _validator = validator ?? ProjectValidator(),
        _uuid = uuid ?? const Uuid();

  Future<Either<Failure, Project>> call(CreateProjectParams params) async {
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
      id: _uuid.v4(),
      clientName: params.clientName,
      projectName: params.projectName,
      description: params.description,
      status: params.status,
      priority: params.priority,
      startDate: params.startDate,
      dueDate: params.dueDate,
    );

    return _repository.createProject(project);
  }
}
