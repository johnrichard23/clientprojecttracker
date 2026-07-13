/// How urgently a project needs attention.
enum ProjectPriority {
  low,
  medium,
  high;

  String get label => switch (this) {
        ProjectPriority.low => 'Low',
        ProjectPriority.medium => 'Medium',
        ProjectPriority.high => 'High',
      };

  /// Reverse of [label]. Throws [ArgumentError] rather than silently
  /// defaulting when [label] doesn't match any known priority - see
  /// docs/system_requirements.md, seed data import.
  static ProjectPriority fromLabel(String label) {
    return ProjectPriority.values.firstWhere(
      (priority) => priority.label == label,
      orElse: () =>
          throw ArgumentError('Unknown ProjectPriority label: "$label"'),
    );
  }
}
