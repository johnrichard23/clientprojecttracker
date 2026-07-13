import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';

/// Status and priority filter chips for the Project List screen, combinable
/// with each other and with search. See docs/system_requirements.md,
/// Section 2.1.
class ProjectFilterChips extends ConsumerWidget {
  const ProjectFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(projectFilterProvider);
    final notifier = ref.read(projectFilterProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final status in ProjectStatus.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status.label),
                selected: filter.status == status,
                onSelected: (selected) =>
                    notifier.setStatusFilter(selected ? status : null),
              ),
            ),
          const SizedBox(width: 8),
          for (final priority in ProjectPriority.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(priority.label),
                selected: filter.priority == priority,
                onSelected: (selected) =>
                    notifier.setPriorityFilter(selected ? priority : null),
              ),
            ),
        ],
      ),
    );
  }
}
