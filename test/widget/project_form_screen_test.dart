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
import 'package:client_project_tracker/features/projects/domain/usecases/create_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/update_project.dart';
import 'package:client_project_tracker/features/projects/presentation/screens/project_form_screen.dart';

class MockGetProjectById extends Mock implements GetProjectById {}

class MockCreateProject extends Mock implements CreateProject {}

class MockUpdateProject extends Mock implements UpdateProject {}

void main() {
  late MockGetProjectById mockGetProjectById;
  late MockCreateProject mockCreateProject;
  late MockUpdateProject mockUpdateProject;

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

  setUpAll(() {
    registerFallbackValue(CreateProjectParams(
      clientName: 'fallback',
      projectName: 'fallback',
      description: '',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      startDate: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 1, 2),
    ),);
    registerFallbackValue(UpdateProjectParams(
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
    mockGetProjectById = MockGetProjectById();
    mockCreateProject = MockCreateProject();
    mockUpdateProject = MockUpdateProject();
  });

  void growSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpCreateScreen(WidgetTester tester) {
    growSurface(tester);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          createProjectProvider.overrideWithValue(mockCreateProject),
        ],
        child: const MaterialApp(home: ProjectFormScreen.create()),
      ),
    );
  }

  Future<void> pumpEditScreen(WidgetTester tester) {
    growSurface(tester);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          getProjectByIdProvider.overrideWithValue(mockGetProjectById),
          updateProjectProvider.overrideWithValue(mockUpdateProject),
        ],
        child: const MaterialApp(
          home: ProjectFormScreen.edit(projectId: projectId),
        ),
      ),
    );
  }

  group('create mode', () {
    testWidgets('renders all fields with sensible defaults', (tester) async {
      await pumpCreateScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Create Project'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Client Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Project Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Description'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Select a date'), findsNWidgets(2));
    });

    testWidgets(
        'blocks submission and shows inline errors when dates are missing',
        (tester) async {
      await pumpCreateScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Client Name'), 'Acme Corp',);
      await tester.enterText(
          find.widgetWithText(TextField, 'Project Name'), 'Website Revamp',);

      await tester.tap(find.widgetWithText(FilledButton, 'Create Project'));
      await tester.pumpAndSettle();

      expect(find.text('Start date is required.'), findsOneWidget);
      expect(find.text('Due date is required.'), findsOneWidget);
      verifyNever(() => mockCreateProject(any()));
    });
  });

  group('edit mode', () {
    testWidgets('shows a loading indicator while the project fetch is in flight',
        (tester) async {
      when(() => mockGetProjectById(projectId)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 50),
          () => Right(project),
        ),
      );

      await pumpEditScreen(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows an error state when the project fetch fails',
        (tester) async {
      const failure =
          NotFoundFailure('No project found with id "$projectId".');
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => const Left(failure));

      await pumpEditScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text(failure.toUserMessage()), findsOneWidget);
    });

    testWidgets('seeds all fields from the existing project once loaded',
        (tester) async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));

      await pumpEditScreen(tester);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Acme Corp'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Website Revamp'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Full redesign of the marketing site.'),
          findsOneWidget,);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Jul 1, 2026'), findsOneWidget);
      expect(find.text('Aug 1, 2026'), findsOneWidget);
    });

    testWidgets(
        'shows an inline field error and preserves other values when the '
        'update fails validation', (tester) async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      await pumpEditScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Acme Corp'), '',);

      const failure = ValidationFailure(
        'Please fix the highlighted fields.',
        fieldErrors: {'clientName': 'Client name is required.'},
      );
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => const Left(failure));

      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Client name is required.'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Website Revamp'), findsOneWidget);
    });

    testWidgets(
        'shows a non-field error banner and preserves entered data on '
        'failure', (tester) async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      await pumpEditScreen(tester);
      await tester.pumpAndSettle();

      const failure = DatabaseFailure('boom');
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => const Left(failure));

      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text(failure.toUserMessage()), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
      expect(find.widgetWithText(TextField, 'Acme Corp'), findsOneWidget);
    });

    testWidgets('pops back to the previous screen on a successful update',
        (tester) async {
      when(() => mockGetProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(() => mockUpdateProject(any()))
          .thenAnswer((_) async => Right(project));

      growSurface(tester);
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/edit',
            builder: (context, state) =>
                const ProjectFormScreen.edit(projectId: projectId),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getProjectByIdProvider.overrideWithValue(mockGetProjectById),
            updateProjectProvider.overrideWithValue(mockUpdateProject),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      unawaited(router.push('/edit'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormScreen), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
