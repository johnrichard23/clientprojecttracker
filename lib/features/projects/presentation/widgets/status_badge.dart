import 'package:flutter/material.dart';

import 'package:client_project_tracker/core/theme/app_colors.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

/// Colored chip showing a project's status, readable in both light and dark
/// mode. See docs/system_requirements.md, Section 2.1 and Section 4
/// (Accessibility).
class StatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = switch (status) {
      ProjectStatus.planning => AppColors.neutral(brightness),
      ProjectStatus.inProgress => AppColors.info(brightness),
      ProjectStatus.onHold => AppColors.warning(brightness),
      ProjectStatus.completed => AppColors.success(brightness),
      ProjectStatus.cancelled => AppColors.danger(brightness),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
