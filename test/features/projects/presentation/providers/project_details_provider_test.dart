import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/delete_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_details_provider.dart';

class MockGetProjectById extends Mock implements GetProjectById {}

class MockDeleteProject extends Mock implements DeleteProject {}

void main() {
  late MockGetProjectById mockGetProjectById;
  late MockDeleteProject mockDeleteProject;
  late ProviderContainer container;

  const projectId = 'project-1';
  final project = Project(
    id: projectId,
    clientName: 'Acme Corp',
    projectName: 'Website Revamp',
    description: 'Full redesign of the marketing site.',
    status: ProjectStatus.planning,
    priority: ProjectPriority.medium,
    startDate: DateTime(2026, 7, 1),
    dueDate: DateTime(2026, 8, 1),
  );

  setUp(() {
    mockGetProjectById = MockGetProjectById();
    mockDeleteProject = MockDeleteProject();
    container = ProviderContainer(overrides: [
      getProjectByIdProvider.overrideWithValue(mockGetProjectById),
      deleteProjectProvider.overrideWithValue(mockDeleteProject),
    ]);
    addTearDown(container.dispose);
  });

  test('emits loading then data when the fetch succeeds', () async {
    when(() => mockGetProjectById(projectId))
        .thenAnswer((_) async => Right(project));

    final states = <AsyncValue<Project>>[];
    container.listen(
      projectDetailsProvider(projectId),
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    await container.read(projectDetailsProvider(projectId).future);

    expect(states.first, isA<AsyncLoading<Project>>());
    expect(states.last, isA<AsyncData<Project>>());
    expect(states.last.value, project);
  });

  test('emits loading then error when the fetch fails', () async {
    final failure = NotFoundFailure('No project found with id "$projectId".');
    when(() => mockGetProjectById(projectId))
        .thenAnswer((_) async => Left(failure));

    final states = <AsyncValue<Project>>[];
    container.listen(
      projectDetailsProvider(projectId),
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    await container
        .read(projectDetailsProvider(projectId).future)
        .catchError((_) => project);

    expect(states.first, isA<AsyncLoading<Project>>());
    expect(states.last, isA<AsyncError<Project>>());
    expect(states.last.error, failure);
  });

  group('delete', () {
    test(
        'calls DeleteProject, returns Right(unit), and re-fetching afterwards '
        'surfaces the resulting NotFoundFailure', () async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      await container.read(projectDetailsProvider(projectId).future);

      final notFound =
          NotFoundFailure('No project found with id "$projectId".');
      when(() => mockDeleteProject(projectId))
          .thenAnswer((_) async => const Right(unit));
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Left(notFound));

      final result = await container
          .read(projectDetailsProvider(projectId).notifier)
          .delete();

      expect(result, const Right<Failure, Unit>(unit));
      final state = container.read(projectDetailsProvider(projectId));
      expect(state, isA<AsyncError<Project>>());
      expect(state.error, notFound);
      verify(() => mockDeleteProject(projectId)).called(1);
    });

    test(
        'returns Left(failure) and leaves the existing data in place when '
        'delete fails', () async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      await container.read(projectDetailsProvider(projectId).future);

      final failure = DatabaseFailure('boom');
      when(() => mockDeleteProject(projectId))
          .thenAnswer((_) async => Left(failure));

      final result = await container
          .read(projectDetailsProvider(projectId).notifier)
          .delete();

      expect(result, Left<Failure, Unit>(failure));
      final state = container.read(projectDetailsProvider(projectId));
      expect(state, isA<AsyncData<Project>>());
      expect(state.value, project);
    });
  });
}
