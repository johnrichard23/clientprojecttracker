import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/features/projects/data/datasources/project_seed_loader.dart';
import 'package:client_project_tracker/features/projects/data/mappers/project_mapper.dart';

// Two entries, copied verbatim from assets/test_data.json, used as the
// fixture "asset" the loader reads.
const _seedJson = '''
[
{
"id": 1,
"clientName": "Acme Corporation",
"projectName": "Corporate Website Redesign",
"description": "Redesign and modernize the company's corporate website.",
"status": "In Progress",
"priority": "High",
"startDate": "2026-06-01",
"dueDate": "2026-07-15"
},
{
"id": 2,
"clientName": "GreenLeaf Cafe",
"projectName": "Online Ordering System",
"description": "Develop an online ordering platform for customers.",
"status": "Planning",
"priority": "Medium",
"startDate": "2026-06-10",
"dueDate": "2026-08-01"
}
]
''';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('seeds the table from the loaded json when it is empty', () async {
    final loader = ProjectSeedLoader(db, loadJson: () async => _seedJson);

    await loader.seedIfEmpty();

    final rows = await db.select(db.projectsTable).get();
    expect(rows, hasLength(2));
    final entities = rows.map((r) => r.toEntity()).toList();
    expect(entities.map((e) => e.id), containsAll(<String>['1', '2']));
    expect(
      entities.map((e) => e.clientName),
      containsAll(<String>['Acme Corporation', 'GreenLeaf Cafe']),
    );
  });

  test('does nothing when the table already has data', () async {
    await db.into(db.projectsTable).insert(ProjectsTableCompanion.insert(
          id: 'existing',
          clientName: 'Existing Client',
          projectName: 'Existing Project',
          status: 'planning',
          priority: 'medium',
          startDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 1, 2),
        ));

    var loadJsonCalled = false;
    final loader = ProjectSeedLoader(db, loadJson: () async {
      loadJsonCalled = true;
      return _seedJson;
    });

    await loader.seedIfEmpty();

    expect(loadJsonCalled, isFalse);
    final rows = await db.select(db.projectsTable).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'existing');
  });
}
