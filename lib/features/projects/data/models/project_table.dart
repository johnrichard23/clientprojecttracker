import 'package:drift/drift.dart';

/// Drift table = the persistence-layer Model (docs/constitution.md, Section 5).
/// Status and priority are stored as text so the DB stays human-readable and
/// migrations don't depend on enum ordering.
class ProjectsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientName => text().withLength(min: 1, max: 120)();
  TextColumn get projectName => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  TextColumn get priority => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
