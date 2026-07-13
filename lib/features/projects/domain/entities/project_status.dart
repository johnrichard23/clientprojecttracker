/// The lifecycle state of a client project.
///
/// Kept as a fixed enum (rather than free-text) so filtering and reporting
/// stay meaningful - see docs/system_requirements.md, Section 1.
enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled;

  String get label => switch (this) {
        ProjectStatus.planning => 'Planning',
        ProjectStatus.inProgress => 'In Progress',
        ProjectStatus.onHold => 'On Hold',
        ProjectStatus.completed => 'Completed',
        ProjectStatus.cancelled => 'Cancelled',
      };
}
