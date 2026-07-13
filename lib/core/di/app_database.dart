import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:client_project_tracker/features/projects/data/models/project_table.dart';

part 'app_database.g.dart';

/// Single source of truth for local persistence. Run
/// `dart run build_runner build --delete-conflicting-outputs` after editing
/// this file or any table definition to regenerate app_database.g.dart.
@DriftDatabase(tables: [ProjectsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Tests should use AppDatabase.forTesting(NativeDatabase.memory()) instead
  // of this constructor, so nothing touches the filesystem.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'project_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
