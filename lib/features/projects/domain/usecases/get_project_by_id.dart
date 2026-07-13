import 'package:fpdart/fpdart.dart';

import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';

/// Fetches a single project by id. See docs/architecture.md, Section 6.
class GetProjectById {
  final ProjectRepository _repository;

  GetProjectById(this._repository);

  Future<Either<Failure, Project>> call(String id) {
    return _repository.getProjectById(id);
  }
}
