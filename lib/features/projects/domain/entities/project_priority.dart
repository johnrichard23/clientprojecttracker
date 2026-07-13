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
}
