import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/features/projects/data/datasources/project_seed_loader.dart';
import 'package:client_project_tracker/features/projects/data/repositories/project_repository_impl.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/create_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/delete_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_projects.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/update_project.dart';

/// Single AppDatabase instance for the app's lifetime. Closed on dispose so
/// tests that create a fresh ProviderContainer per test don't leak
/// connections. See docs/architecture.md, Section 5 (Memory Management).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Data layer: repository implementation, wired to the shared database.
/// See docs/architecture.md, Section 4 (Dependency Injection).
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Domain layer: use cases, each a thin provider-wrapped class taking its
/// dependencies via constructor injection only.
final getProjectsProvider = Provider<GetProjects>((ref) {
  return GetProjects(ref.watch(projectRepositoryProvider));
});

final getProjectByIdProvider = Provider<GetProjectById>((ref) {
  return GetProjectById(ref.watch(projectRepositoryProvider));
});

final createProjectProvider = Provider<CreateProject>((ref) {
  return CreateProject(ref.watch(projectRepositoryProvider));
});

final updateProjectProvider = Provider<UpdateProject>((ref) {
  return UpdateProject(ref.watch(projectRepositoryProvider));
});

final deleteProjectProvider = Provider<DeleteProject>((ref) {
  return DeleteProject(ref.watch(projectRepositoryProvider));
});

/// Loads the exam seed data (assets/test_data.json) into an empty database.
/// See docs/architecture.md, Section 4 (Dependency Injection).
final projectSeedLoaderProvider = Provider<ProjectSeedLoader>((ref) {
  return ProjectSeedLoader(
    ref.watch(appDatabaseProvider),
    loadJson: () => rootBundle.loadString('assets/test_data.json'),
  );
});

/// App startup gate. A FutureProvider's body runs once and is cached for
/// the container's lifetime - re-watching it (e.g. on widget rebuild) does
/// not re-run the seed check. See app.dart, which watches this to show a
/// splash until it resolves.
final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.watch(projectSeedLoaderProvider).seedIfEmpty();
});
