import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/data/repositories/project_repository_impl.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

Project _buildProject({
  String id = 'p1',
  String clientName = 'Acme Corp',
  String projectName = 'Website Revamp',
}) {
  return Project(
    id: id,
    clientName: clientName,
    projectName: projectName,
    description: 'Full redesign of the marketing site.',
    status: ProjectStatus.planning,
    priority: ProjectPriority.medium,
    startDate: DateTime(2026, 7, 1),
    dueDate: DateTime(2026, 8, 1),
  );
}

void main() {
  late AppDatabase db;
  late ProjectRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProjectRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('createProject', () {
    test('inserts a project and returns it back as a Right', () async {
      final project = _buildProject();

      final result = await repository.createProject(project);

      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('expected Right, got Left($l)'),
        (r) => expect(r, project),
      );
    });

    test('returns a DatabaseFailure when the id already exists', () async {
      final project = _buildProject();
      await repository.createProject(project);

      final result = await repository.createProject(project);

      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<DatabaseFailure>()),
        (r) => fail('expected Left, got Right($r)'),
      );
    });
  });

  group('getProjects', () {
    test('returns an empty list when no projects exist', () async {
      final result = await repository.getProjects();

      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('expected Right, got Left($l)'),
        (r) => expect(r, isEmpty),
      );
    });

    test('returns all projects once populated', () async {
      final first = _buildProject(id: 'p1', projectName: 'Website Revamp');
      final second = _buildProject(id: 'p2', projectName: 'Mobile App');
      await repository.createProject(first);
      await repository.createProject(second);

      final result = await repository.getProjects();

      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('expected Right, got Left($l)'),
        (r) => expect(r, containsAll(<Project>[first, second])),
      );
    });
  });

  group('getProjectById', () {
    test('returns the project when found', () async {
      final project = _buildProject();
      await repository.createProject(project);

      final result = await repository.getProjectById(project.id);

      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('expected Right, got Left($l)'),
        (r) => expect(r, project),
      );
    });

    test('returns NotFoundFailure when the id does not exist', () async {
      final result = await repository.getProjectById('does-not-exist');

      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<NotFoundFailure>()),
        (r) => fail('expected Left, got Right($r)'),
      );
    });
  });

  group('updateProject', () {
    test('persists changes and returns the updated project', () async {
      final project = _buildProject();
      await repository.createProject(project);
      final updated = project.copyWith(projectName: 'Website Revamp v2');

      final result = await repository.updateProject(updated);

      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('expected Right, got Left($l)'),
        (r) => expect(r, updated),
      );
      final reread = await repository.getProjectById(project.id);
      reread.match(
        (l) => fail('expected Right, got Left($l)'),
        (r) => expect(r.projectName, 'Website Revamp v2'),
      );
    });

    test('returns NotFoundFailure when updating a project that does not exist', () async {
      final result = await repository.updateProject(_buildProject());

      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<NotFoundFailure>()),
        (r) => fail('expected Left, got Right($r)'),
      );
    });
  });

  group('deleteProject', () {
    test('removes an existing project', () async {
      final project = _buildProject();
      await repository.createProject(project);

      final result = await repository.deleteProject(project.id);

      expect(result.isRight(), isTrue);
      final reread = await repository.getProjectById(project.id);
      expect(reread.isLeft(), isTrue);
    });

    test('returns NotFoundFailure when deleting a project that does not exist', () async {
      final result = await repository.deleteProject('does-not-exist');

      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<NotFoundFailure>()),
        (r) => fail('expected Left, got Right($r)'),
      );
    });
  });
}
