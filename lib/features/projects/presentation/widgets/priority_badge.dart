import 'package:flutter/material.dart';

import 'package:client_project_tracker/core/theme/app_colors.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';

/// Colored chip showing a project's priority, readable in both light and
/// dark mode. See docs/system_requirements.md, Section 2.1 and Section 4
/// (Accessibility).
class PriorityBadge extends StatelessWidget {
  final ProjectPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = switch (priority) {
      ProjectPriority.low => AppColors.success(brightness),
      ProjectPriority.medium => AppColors.warning(brightness),
      ProjectPriority.high => AppColors.danger(brightness),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
