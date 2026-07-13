import 'dart:convert';

import 'package:client_project_tracker/core/di/app_database.dart';
import 'package:client_project_tracker/features/projects/data/mappers/project_mapper.dart';
import 'package:client_project_tracker/features/projects/data/models/project_dto.dart';

/// Seeds [ProjectsTable] from the exam seed data (assets/test_data.json) the
/// first time the app runs against an empty database. `loadJson` is
/// injected rather than reading `rootBundle` directly so this stays testable
/// against an in-memory database with a fixture string - see
/// docs/constitution.md, Section 10 (Testing Mandate).
class ProjectSeedLoader {
  final AppDatabase _db;
  final Future<String> Function() _loadJson;

  ProjectSeedLoader(this._db, {required Future<String> Function() loadJson})
      : _loadJson = loadJson;

  Future<void> seedIfEmpty() async {
    final existing =
        await (_db.select(_db.projectsTable)..limit(1)).getSingleOrNull();
    if (existing != null) return;

    final raw = await _loadJson();
    final entries = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final companions = entries
        .map((json) => ProjectDto.fromJson(json).toEntity().toCompanion())
        .toList();

    await _db.batch((batch) {
      batch.insertAll(_db.projectsTable, companions);
    });
  }
}
