import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_projects.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late MockProjectRepository repository;
  late GetProjects useCase;

  setUp(() {
    repository = MockProjectRepository();
    useCase = GetProjects(repository);
  });

  test('returns the list of projects from the repository', () async {
    final projects = [
      Project(
        id: 'p1',
        clientName: 'Acme',
        projectName: 'Website',
        description: '',
        status: ProjectStatus.planning,
        priority: ProjectPriority.medium,
        startDate: DateTime(2026, 1, 1),
        dueDate: DateTime(2026, 2, 1),
      ),
    ];
    when(() => repository.getProjects())
        .thenAnswer((_) async => Right(projects));

    final result = await useCase();

    result.match(
      (l) => fail('expected Right, got Left($l)'),
      (r) => expect(r, projects),
    );
    verify(() => repository.getProjects()).called(1);
  });

  test('passes through a failure from the repository unchanged', () async {
    const failure = DatabaseFailure('boom');
    when(() => repository.getProjects())
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    result.match(
      (l) => expect(l, same(failure)),
      (r) => fail('expected Left, got Right($r)'),
    );
  });
}
