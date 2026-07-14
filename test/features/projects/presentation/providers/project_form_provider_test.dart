import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/create_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_projects.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/update_project.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_details_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_form_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';

class MockCreateProject extends Mock implements CreateProject {}

class MockUpdateProject extends Mock implements UpdateProject {}

class MockGetProjects extends Mock implements GetProjects {}

class MockGetProjectById extends Mock implements GetProjectById {}

void main() {
  late MockCreateProject mockCreateProject;
  late MockUpdateProject mockUpdateProject;
  late MockGetProjects mockGetProjects;
  late MockGetProjectById mockGetProjectById;
  late ProviderContainer container;

  final project = Project(
    id: 'project-1',
    clientName: 'Acme Corp',
    projectName: 'Website Revamp',
    description: 'Full redesign of the marketing site.',
    status: ProjectStatus.planning,
    priority: ProjectPriority.medium,
    startDate: DateTime(2026, 7, 1),
    dueDate: DateTime(2026, 8, 1),
  );

  setUpAll(() {
    registerFallbackValue(CreateProjectParams(
      clientName: 'fallback',
      projectName: 'fallback',
      description: '',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      startDate: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 1, 2),
    ));
    registerFallbackValue(UpdateProjectParams(
      id: 'fallback',
      clientName: 'fallback',
      projectName: 'fallback',
      description: '',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      startDate: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 1, 2),
    ));
  });

  setUp(() {
    mockCreateProject = MockCreateProject();
    mockUpdateProject = MockUpdateProject();
    mockGetProjects = MockGetProjects();
    mockGetProjectById = MockGetProjectById();
    when(() => mockGetProjects()).thenAnswer((_) async => const Right([]));
    container = ProviderContainer(overrides: [
      createProjectProvider.overrideWithValue(mockCreateProject),
      updateProjectProvider.overrideWithValue(mockUpdateProject),
      getProjectsProvider.overrideWithValue(mockGetProjects),
      getProjectByIdProvider.overrideWithValue(mockGetProjectById),
    ]);
    addTearDown(container.dispose);
  });

  Future<void> submit(ProjectFormArgs args, {String clientName = 'Acme Corp'}) {
    return container.read(projectFormProvider(args).notifier).submit(
          clientName: clientName,
          projectName: 'Website Revamp',
          description: 'Full redesign of the marketing site.',
          status: ProjectStatus.planning,
          priority: ProjectPriority.medium,
          startDate: DateTime(2026, 7, 1),
          dueDate: DateTime(2026, 8, 1),
        );
  }

  group('create mode', () {
    const args = ProjectFormArgs.create();

    test('starts as AsyncData(null) - no submission made yet', () async {
      await container.read(projectFormProvider(args).future);
      final state = container.read(projectFormProvider(args));
      expect(state, const AsyncData<Project?>(null));
    });

    test('calls CreateProject and emits AsyncData(project) on success',
        () async {
      when(() => mockCreateProject(any()))
          .thenAnswer((_) async => Right(project));

      await submit(args);

      final state = container.read(projectFormProvider(args));
      expect(state.value, project);
      verify(() => mockCreateProject(any())).called(1);
      verifyNever(() => mockUpdateProject(any()));
    });

    test(
        'surfaces ValidationFailure field errors without touching UpdateProject',
        () async {
      final failure = ValidationFailure(
        'Please fix the highlighted fields.',
        fieldErrors: {'clientName': 'Client name is required.'},
      );
      when(() => mockCreateProject(any()))
          .thenAnswer((_) async => Left(failure));

      await submit(args, clientName: '');

      final state = container.read(projectFormProvider(args));
      expect(state.hasError, isTrue);
      expect(state.error, isA<ValidationFailure>());

      final notifier = container.read(projectFormProvider(args).notifier);
      expect(notifier.fieldErrors, {'clientName': 'Client name is required.'});
      verifyNever(() => mockUpdateProject(any()));
    });

    test('invalidates the project list so it refetches after a successful create',
        () async {
      when(() => mockCreateProject(any()))
          .thenAnswer((_) async => Right(project));

      await container.read(projectListProvider.future);
      verify(() => mockGetProjects()).called(1);

      await submit(args);
      await container.read(projectListProvider.future);

      verify(() => mockGetProjects()).called(1);
    });

    test('does not invalidate the project list when create fails validation',
        () async {
      final failure = ValidationFailure(
        'Please fix the highlighted fields.',
        fieldErrors: {'clientName': 'Client name is required.'},
      );
      when(() => mockCreateProject(any()))
          .thenAnswer((_) async => Left(failure));

      await container.read(projectListProvider.future);
      verify(() => mockGetProjects()).called(1);

      await submit(args, clientName: '');

      verifyNever(() => mockGetProjects());
    });
  });

  group('edit mode', () {
    final args = ProjectFormArgs.edit(project.id);

    test(
        'calls UpdateProject with the existing id and emits AsyncData on success',
        () async {
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => Right(project));

      await submit(args);

      final state = container.read(projectFormProvider(args));
      expect(state.value, project);

      final captured = verify(() => mockUpdateProject(captureAny()))
          .captured
          .single as UpdateProjectParams;
      expect(captured.id, project.id);
      verifyNever(() => mockCreateProject(any()));
    });

    test(
        'surfaces ValidationFailure field errors without touching CreateProject',
        () async {
      final failure = ValidationFailure(
        'Please fix the highlighted fields.',
        fieldErrors: {'dueDate': 'Due date cannot be before the start date.'},
      );
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => Left(failure));

      await submit(args);

      final notifier = container.read(projectFormProvider(args).notifier);
      expect(notifier.fieldErrors,
          {'dueDate': 'Due date cannot be before the start date.'});
      verifyNever(() => mockCreateProject(any()));
    });

    test('invalidates the project list so it refetches after a successful update',
        () async {
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => Right(project));

      await container.read(projectListProvider.future);
      verify(() => mockGetProjects()).called(1);

      await submit(args);
      await container.read(projectListProvider.future);

      verify(() => mockGetProjects()).called(1);
    });

    test(
        'invalidates the details provider for the edited project so it '
        'refetches after a successful update', () async {
      when(() => mockGetProjectById(project.id))
          .thenAnswer((_) async => Right(project));
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => Right(project));

      await container.read(projectDetailsProvider(project.id).future);
      verify(() => mockGetProjectById(project.id)).called(1);

      await submit(args);
      await container.read(projectDetailsProvider(project.id).future);

      verify(() => mockGetProjectById(project.id)).called(1);
    });
  });
}
