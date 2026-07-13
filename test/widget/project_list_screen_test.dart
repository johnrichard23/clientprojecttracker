import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failure_message.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/get_projects.dart';
import 'package:client_project_tracker/features/projects/presentation/screens/project_list_screen.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/priority_badge.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/status_badge.dart';

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGetProjects = MockGetProjects();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getProjectsProvider.overrideWithValue(mockGetProjects),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: ProjectListScreen()),
      ),
    );
  }

  testWidgets(
      'shows a loading indicator while the initial fetch is in flight',
      (tester) async {
    when(() => mockGetProjects()).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => const Right(<Project>[]),
      ),
    );

    await pumpScreen(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'shows the empty state with a create CTA when there are no projects',
      (tester) async {
    when(() => mockGetProjects()).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No projects yet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create your first project'),
        findsOneWidget);
  });

  testWidgets('shows project rows with badges and due date when data loads',
      (tester) async {
    final projects = [
      _project(
        id: '1',
        clientName: 'Acme Corp',
        projectName: 'Website Revamp',
        status: ProjectStatus.inProgress,
        priority: ProjectPriority.high,
      ),
    ];
    when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Website Revamp'), findsOneWidget);
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
    expect(find.text('Feb 1, 2026'), findsOneWidget);
  });

  testWidgets('shows an error message with retry when the fetch fails',
      (tester) async {
    final failure = DatabaseFailure('Failed to load projects: boom');
    when(() => mockGetProjects()).thenAnswer((_) async => Left(failure));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text(failure.toUserMessage()), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);

    final projects = [_project(id: '1')];
    when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
  });

  testWidgets('search text narrows the visible list', (tester) async {
    final projects = [
      _project(id: '1', clientName: 'Acme Corp', projectName: 'Website'),
      _project(id: '2', clientName: 'Beta LLC', projectName: 'App Revamp'),
    ];
    when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Beta LLC'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'revamp');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsNothing);
    expect(find.text('Beta LLC'), findsOneWidget);
  });

  testWidgets('status filter chip narrows the visible list', (tester) async {
    final projects = [
      _project(
          id: '1', clientName: 'Acme Corp', status: ProjectStatus.inProgress),
      _project(
          id: '2', clientName: 'Beta LLC', status: ProjectStatus.completed),
    ];
    when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Beta LLC'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'In Progress'));
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Beta LLC'), findsNothing);
  });

  testWidgets('priority filter chip narrows the visible list', (tester) async {
    final projects = [
      _project(
          id: '1', clientName: 'Acme Corp', priority: ProjectPriority.high),
      _project(
          id: '2', clientName: 'Beta LLC', priority: ProjectPriority.low),
    ];
    when(() => mockGetProjects()).thenAnswer((_) async => Right(projects));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final highChip = find.widgetWithText(FilterChip, 'High');
    await tester.ensureVisible(highChip);
    await tester.pumpAndSettle();
    await tester.tap(highChip);
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Beta LLC'), findsNothing);
  });
}
