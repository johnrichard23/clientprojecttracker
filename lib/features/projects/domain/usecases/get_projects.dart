import 'package:fpdart/fpdart.dart';

import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';

/// Fetches all projects. See docs/architecture.md, Section 6.
class GetProjects {
  final ProjectRepository _repository;

  GetProjects(this._repository);

  Future<Either<Failure, List<Project>>> call() {
    return _repository.getProjects();
  }
}
