import 'package:fpdart/fpdart.dart';

import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/data/mappers/project_mapper.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';

/// Drift-backed implementation of [ProjectRepository]. Any storage exception
/// is caught here and converted to a [Failure] - see
/// docs/constitution.md, Section 9.
class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _db;

  ProjectRepositoryImpl(this._db);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final rows = await _db.select(_db.projectsTable).get();
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to load projects: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final row = await (_db.select(_db.projectsTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return Left(NotFoundFailure('No project found with id "$id".'));
      }
      return Right(row.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to load project "$id": $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      await _db.into(_db.projectsTable).insert(project.toCompanion());
      return Right(project);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create project: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      final updatedRows = await (_db.update(_db.projectsTable)
            ..where((t) => t.id.equals(project.id)))
          .write(project.toCompanion());
      if (updatedRows == 0) {
        return Left(NotFoundFailure('No project found with id "${project.id}".'));
      }
      return Right(project);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update project "${project.id}": $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(String id) async {
    try {
      final deletedRows = await (_db.delete(_db.projectsTable)
            ..where((t) => t.id.equals(id)))
          .go();
      if (deletedRows == 0) {
        return Left(NotFoundFailure('No project found with id "$id".'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete project "$id": $e'));
    }
  }
}
