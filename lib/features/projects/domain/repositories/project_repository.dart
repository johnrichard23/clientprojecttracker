import 'package:fpdart/fpdart.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';

/// Contract for project persistence. Implemented in the data layer
/// (see lib/features/projects/data/repositories/project_repository_impl.dart).
///
/// Domain and presentation code depend on this interface only - never on the
/// concrete implementation. See docs/architecture.md, Section 4.
abstract interface class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();

  Future<Either<Failure, Project>> getProjectById(String id);

  Future<Either<Failure, Project>> createProject(Project project);

  Future<Either<Failure, Project>> updateProject(Project project);

  Future<Either<Failure, Unit>> deleteProject(String id);
}
