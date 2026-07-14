import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:client_project_tracker/core/errors/failure_message.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/core/router/app_router.dart';
import 'package:client_project_tracker/core/utils/date_formatter.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_details_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/priority_badge.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/status_badge.dart';

/// Shows a single project's full details. See docs/system_requirements.md,
/// Section 2.4.
class ProjectDetailsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'This will permanently delete this project. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result =
        await ref.read(projectDetailsProvider(projectId).notifier).delete();

    if (!context.mounted) return;

    result.match(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.toUserMessage())),
        );
      },
      (_) {
        ref.invalidate(projectListProvider);
        context.go(AppRoutes.projectList);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(projectDetailsProvider(projectId));

    return detailsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is Failure
                  ? error.toUserMessage()
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (project) => Scaffold(
        appBar: AppBar(
          title: Text(project.projectName),
          actions: [
            IconButton(
              tooltip: 'Edit project',
              icon: const Icon(Icons.edit),
              onPressed: () => context
                  .push(AppRoutes.projectEditPath(project.id)),
            ),
            IconButton(
              tooltip: 'Delete project',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmAndDelete(context, ref),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                project.clientName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                project.projectName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  StatusBadge(status: project.status),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: project.priority),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                label: 'Start Date',
                value: DateFormatter.short(project.startDate),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Due Date',
                value: DateFormatter.short(project.dueDate),
              ),
              const SizedBox(height: 24),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                project.description.isEmpty
                    ? 'No description provided.'
                    : project.description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
