import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/create_project.dart';
import 'package:fpdart/fpdart.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late MockProjectRepository repository;
  late CreateProject useCase;

  setUpAll(() {
    registerFallbackValue(Project(
      id: 'fallback',
      clientName: 'fallback',
      projectName: 'fallback',
      description: '',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      startDate: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 1, 2),
    ),);
  });

  setUp(() {
    repository = MockProjectRepository();
    useCase = CreateProject(repository);
  });

  final validParams = CreateProjectParams(
    clientName: 'Acme Corp',
    projectName: 'Website Revamp',
    description: 'Full redesign of the marketing site.',
    status: ProjectStatus.planning,
    priority: ProjectPriority.medium,
    startDate: DateTime(2026, 7, 1),
    dueDate: DateTime(2026, 8, 1),
  );

  test(
      'returns a ValidationFailure and never calls the repository when input is invalid',
      () async {
    final invalidParams = CreateProjectParams(
      clientName: '',
      projectName: 'Website Revamp',
      description: '',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      startDate: DateTime(2026, 7, 1),
      dueDate: DateTime(2026, 8, 1),
    );

    final result = await useCase(invalidParams);

    result.match(
      (l) {
        expect(l, isA<ValidationFailure>());
        expect((l as ValidationFailure).fieldErrors.containsKey('clientName'),
            isTrue,);
      },
      (r) => fail('expected Left, got Right($r)'),
    );
    verifyNever(() => repository.createProject(any()));
  });

  test(
      'generates an id, builds a Project from valid input, and delegates to the repository',
      () async {
    when(() => repository.createProject(any())).thenAnswer(
        (invocation) async => Right(invocation.positionalArguments[0] as Project),);

    final result = await useCase(validParams);

    final captured =
        verify(() => repository.createProject(captureAny())).captured.single
            as Project;
    expect(captured.id, isNotEmpty);
    expect(captured.clientName, validParams.clientName);
    expect(captured.projectName, validParams.projectName);
    expect(captured.description, validParams.description);
    expect(captured.status, validParams.status);
    expect(captured.priority, validParams.priority);
    expect(captured.startDate, validParams.startDate);
    expect(captured.dueDate, validParams.dueDate);

    result.match(
      (l) => fail('expected Right, got Left($l)'),
      (r) => expect(r.id, captured.id),
    );
  });
}
