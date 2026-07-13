import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_project_by_id.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late MockProjectRepository repository;
  late GetProjectById useCase;

  setUp(() {
    repository = MockProjectRepository();
    useCase = GetProjectById(repository);
  });

  final project = Project(
    id: 'p1',
    clientName: 'Acme',
    projectName: 'Website',
    description: '',
    status: ProjectStatus.planning,
    priority: ProjectPriority.medium,
    startDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 2, 1),
  );

  test('returns the project from the repository when found', () async {
    when(() => repository.getProjectById('p1'))
        .thenAnswer((_) async => Right(project));

    final result = await useCase('p1');

    result.match(
      (l) => fail('expected Right, got Left($l)'),
      (r) => expect(r, project),
    );
    verify(() => repository.getProjectById('p1')).called(1);
  });

  test('passes through a NotFoundFailure from the repository unchanged', () async {
    const failure = NotFoundFailure('No project found with id "missing".');
    when(() => repository.getProjectById('missing'))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase('missing');

    result.match(
      (l) => expect(l, same(failure)),
      (r) => fail('expected Left, got Right($r)'),
    );
  });
}
