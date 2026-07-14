import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failure_message.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/delete_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_projects.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/screens/project_details_screen.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/priority_badge.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/status_badge.dart';

class MockGetProjectById extends Mock implements GetProjectById {}

class MockDeleteProject extends Mock implements DeleteProject {}

class MockGetProjects extends Mock implements GetProjects {}

void main() {
  late MockGetProjectById mockGetProjectById;
  late MockDeleteProject mockDeleteProject;
  late MockGetProjects mockGetProjects;

  const projectId = 'project-1';
  final project = Project(
    id: projectId,
    clientName: 'Acme Corp',
    projectName: 'Website Revamp',
    description: 'Full redesign of the marketing site.',
    status: ProjectStatus.inProgress,
    priority: ProjectPriority.high,
    startDate: DateTime(2026, 7, 1),
    dueDate: DateTime(2026, 8, 1),
  );

  setUp(() {
    mockGetProjectById = MockGetProjectById();
    mockDeleteProject = MockDeleteProject();
    mockGetProjects = MockGetProjects();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          getProjectByIdProvider.overrideWithValue(mockGetProjectById),
          deleteProjectProvider.overrideWithValue(mockDeleteProject),
        ],
        child: const MaterialApp(
          home: ProjectDetailsScreen(projectId: projectId),
        ),
      ),
    );
  }

  testWidgets('shows a loading indicator while the fetch is in flight',
      (tester) async {
    when(() => mockGetProjectById(projectId)).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => Right(project),
      ),
    );

    await pumpScreen(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('shows all fields, fully formatted, once the project loads',
      (tester) async {
    when(() => mockGetProjectById(projectId))
        .thenAnswer((_) async => Right(project));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    // Appears once in the AppBar title and once in the body.
    expect(find.text('Website Revamp'), findsNWidgets(2));
    expect(find.text('Full redesign of the marketing site.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StatusBadge),
        matching: find.text('In Progress'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PriorityBadge),
        matching: find.text('High'),
      ),
      findsOneWidget,
    );
    expect(find.text('Jul 1, 2026'), findsOneWidget);
    expect(find.text('Aug 1, 2026'), findsOneWidget);
  });

  testWidgets('shows an error state when the project cannot be found',
      (tester) async {
    const failure = NotFoundFailure('No project found with id "$projectId".');
    when(() => mockGetProjectById(projectId))
        .thenAnswer((_) async => const Left(failure));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text(failure.toUserMessage()), findsOneWidget);
  });

  group('delete', () {
    testWidgets(
        'shows a confirmation dialog and does not delete when cancelled',
        (tester) async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      verifyNever(() => mockDeleteProject(any()));
    });

    testWidgets(
        'invalidates the project list and navigates back to it on '
        'successful delete', (tester) async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(() => mockDeleteProject(projectId))
          .thenAnswer((_) async => const Right(unit));
      when(() => mockGetProjects()).thenAnswer((_) async => const Right([]));

      final container = ProviderContainer(
        overrides: [
          getProjectByIdProvider.overrideWithValue(mockGetProjectById),
          deleteProjectProvider.overrideWithValue(mockDeleteProject),
          getProjectsProvider.overrideWithValue(mockGetProjects),
        ],
      );
      addTearDown(container.dispose);

      // Keep projectListProvider alive & listened, as the real list screen
      // does while mounted, so that invalidating it below triggers an
      // eager refetch rather than a lazy one nobody observes.
      container.listen(projectListProvider, (_, __) {});
      await container.read(projectListProvider.future);
      verify(() => mockGetProjects()).called(1);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/details',
            builder: (context, state) =>
                const ProjectDetailsScreen(projectId: projectId),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      unawaited(router.push('/details'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => mockDeleteProject(projectId)).called(1);
      // The refetch triggered by ref.invalidate(projectListProvider).
      verify(() => mockGetProjects()).called(1);
      expect(find.byType(ProjectDetailsScreen), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
