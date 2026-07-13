import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/delete_project.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late MockProjectRepository repository;
  late DeleteProject useCase;

  setUp(() {
    repository = MockProjectRepository();
    useCase = DeleteProject(repository);
  });

  test('deletes the project via the repository and returns Right(unit)', () async {
    when(() => repository.deleteProject('p1'))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase('p1');

    result.match(
      (l) => fail('expected Right, got Left($l)'),
      (r) => expect(r, unit),
    );
    verify(() => repository.deleteProject('p1')).called(1);
  });

  test('passes through a NotFoundFailure from the repository unchanged', () async {
    const failure = NotFoundFailure('No project found with id "missing".');
    when(() => repository.deleteProject('missing'))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase('missing');

    result.match(
      (l) => expect(l, same(failure)),
      (r) => fail('expected Left, got Right($r)'),
    );
  });
}
