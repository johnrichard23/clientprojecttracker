import 'package:flutter/material.dart';

import 'package:client_project_tracker/core/utils/date_formatter.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/priority_badge.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/status_badge.dart';

/// One row on the Project List screen: client name, project name, status
/// and priority badges, and due date. See docs/system_requirements.md,
/// Section 2.1.
class ProjectListTile extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectListTile({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(project.projectName),
      subtitle: Text(project.clientName),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge(status: project.status),
              const SizedBox(width: 6),
              PriorityBadge(priority: project.priority),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormatter.short(project.dueDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
