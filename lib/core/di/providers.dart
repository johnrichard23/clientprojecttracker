import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/app_database.dart';

/// Single AppDatabase instance for the app's lifetime. Closed on dispose so
/// tests that create a fresh ProviderContainer per test don't leak
/// connections. See docs/architecture.md, Section 5 (Memory Management).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
