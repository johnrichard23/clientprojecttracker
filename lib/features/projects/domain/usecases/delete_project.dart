import 'package:fpdart/fpdart.dart';

import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';

/// Deletes a project by id. See docs/architecture.md, Section 6.
class DeleteProject {
  final ProjectRepository _repository;

  DeleteProject(this._repository);

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteProject(id);
  }
}
