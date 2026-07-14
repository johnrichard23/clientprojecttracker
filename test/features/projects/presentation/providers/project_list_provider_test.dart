import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_projects.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';

class MockGetProjects extends Mock implements GetProjects {}

Project _project({
  required String id,
  String clientName = 'Acme Corp',
  String projectName = 'Website Revamp',
  ProjectStatus status = ProjectStatus.planning,
  ProjectPriority priority = ProjectPriority.medium,
}) {
  return Project(
    id: id,
    clientName: clientName,
    projectName: projectName,
    description: '',
    status: status,
    priority: priority,
    startDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 2, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetProjects mockGetProjects;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockGetProjects = MockGetProjects();
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      getProjectsProvider.overrideWithValue(mockGetProjects),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],);
    addTearDown(container.dispose);
  });

  group('ProjectListNotifier', () {
    test('emits loading then data when the use case succeeds', () async {
      final projects = [_project(id: '1'), _project(id: '2')];
      when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));

      final states = <AsyncValue<List<Project>>>[];
      container.listen(
        projectListProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(projectListProvider.future);

      expect(states.first, isA<AsyncLoading<List<Project>>>());
      expect(states.last, isA<AsyncData<List<Project>>>());
      expect(states.last.value, projects);
    });

    test('emits loading then error when the use case fails', () async {
      const failure = DatabaseFailure('boom');
      when(() => mockGetProjects()).thenAnswer((_) async => const Left(failure));

      final states = <AsyncValue<List<Project>>>[];
      container.listen(
        projectListProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await container
          .read(projectListProvider.future)
          .catchError((_) => <Project>[]);

      expect(states.first, isA<AsyncLoading<List<Project>>>());
      expect(states.last, isA<AsyncError<List<Project>>>());
      expect(states.last.error, failure);
    });
  });

  group('ProjectFilterNotifier', () {
    test('starts from empty defaults when nothing persisted', () {
      final filter = container.read(projectFilterProvider);
      expect(filter.searchText, '');
      expect(filter.status, isNull);
      expect(filter.priority, isNull);
    });

    test('setSearchText updates state and persists it', () {
      container.read(projectFilterProvider.notifier).setSearchText('acme');
      expect(container.read(projectFilterProvider).searchText, 'acme');

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('project_filter_search_text'), 'acme');
    });

    test('setStatusFilter updates state and persists it, null clears it', () {
      final notifier = container.read(projectFilterProvider.notifier);
      final prefs = container.read(sharedPreferencesProvider);

      notifier.setStatusFilter(ProjectStatus.inProgress);
      expect(container.read(projectFilterProvider).status,
          ProjectStatus.inProgress,);
      expect(prefs.getString('project_filter_status'), 'inProgress');

      notifier.setStatusFilter(null);
      expect(container.read(projectFilterProvider).status, isNull);
      expect(prefs.containsKey('project_filter_status'), isFalse);
    });

    test('setPriorityFilter updates state and persists it', () {
      final notifier = container.read(projectFilterProvider.notifier);
      notifier.setPriorityFilter(ProjectPriority.high);
      expect(
          container.read(projectFilterProvider).priority, ProjectPriority.high,);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('project_filter_priority'), 'high');
    });

    test('clearFilters resets and un-persists all fields', () {
      final notifier = container.read(projectFilterProvider.notifier);
      final prefs = container.read(sharedPreferencesProvider);
      notifier.setSearchText('acme');
      notifier.setStatusFilter(ProjectStatus.inProgress);
      notifier.setPriorityFilter(ProjectPriority.high);

      notifier.clearFilters();

      expect(container.read(projectFilterProvider), const ProjectListFilter());
      expect(prefs.getString('project_filter_search_text'), '');
      expect(prefs.containsKey('project_filter_status'), isFalse);
      expect(prefs.containsKey('project_filter_priority'), isFalse);
    });

    test('reads persisted filter/search on initial build', () async {
      SharedPreferences.setMockInitialValues({
        'project_filter_search_text': 'acme',
        'project_filter_status': 'onHold',
        'project_filter_priority': 'low',
      });
      final prefs = await SharedPreferences.getInstance();
      final freshContainer = ProviderContainer(overrides: [
        getProjectsProvider.overrideWithValue(mockGetProjects),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],);
      addTearDown(freshContainer.dispose);

      final filter = freshContainer.read(projectFilterProvider);
      expect(filter.searchText, 'acme');
      expect(filter.status, ProjectStatus.onHold);
      expect(filter.priority, ProjectPriority.low);
    });
  });

  group('filteredProjectListProvider', () {
    test('filters by search text across client and project name', () async {
      final projects = [
        _project(id: '1', clientName: 'Acme Corp', projectName: 'Website'),
        _project(id: '2', clientName: 'Beta LLC', projectName: 'App Revamp'),
      ];
      when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));
      await container.read(projectListProvider.future);

      container.read(projectFilterProvider.notifier).setSearchText('revamp');

      final filtered = container.read(filteredProjectListProvider);
      expect(filtered.value, [projects[1]]);
    });

    test('combines search with status and priority filters', () async {
      final projects = [
        _project(
            id: '1',
            status: ProjectStatus.inProgress,
            priority: ProjectPriority.high,),
        _project(
            id: '2',
            status: ProjectStatus.inProgress,
            priority: ProjectPriority.low,),
        _project(
            id: '3',
            status: ProjectStatus.completed,
            priority: ProjectPriority.high,),
      ];
      when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));
      await container.read(projectListProvider.future);

      final notifier = container.read(projectFilterProvider.notifier);
      notifier.setStatusFilter(ProjectStatus.inProgress);
      notifier.setPriorityFilter(ProjectPriority.high);

      final filtered = container.read(filteredProjectListProvider);
      expect(filtered.value, [projects[0]]);
    });

    test('propagates the loading/error state of the underlying list', () async {
      const failure = DatabaseFailure('boom');
      when(() => mockGetProjects()).thenAnswer((_) async => const Left(failure));

      await container
          .read(projectListProvider.future)
          .catchError((_) => <Project>[]);

      final filtered = container.read(filteredProjectListProvider);
      expect(filtered, isA<AsyncError<List<Project>>>());
    });
  });
}
