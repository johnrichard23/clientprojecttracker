import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:client_project_tracker/core/errors/failure_message.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/core/router/app_router.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/project_filter_chips.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/project_list_tile.dart';
import 'package:client_project_tracker/features/projects/presentation/widgets/project_search_bar.dart';

/// The app's home screen: all projects, with search + status/priority
/// filters. See docs/system_requirements.md, Section 2.1.
class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProjectListProvider);
    final filter = ref.watch(projectFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create project',
        onPressed: () => context.push(AppRoutes.projectCreate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const ProjectSearchBar(),
          const SizedBox(height: 8),
          const ProjectFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: error is Failure
                    ? error.toUserMessage()
                    : 'Something went wrong. Please try again.',
                onRetry: () => ref.read(projectListProvider.notifier).refresh(),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return filter.isEmpty
                      ? _EmptyState(
                          onCreate: () => context.push(AppRoutes.projectCreate),
                        )
                      : _NoMatchesState(
                          onClearFilters: () => ref
                              .read(projectFilterProvider.notifier)
                              .clearFilters(),
                        );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(projectListProvider.notifier).refresh(),
                  child: ListView.separated(
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectListTile(
                        project: project,
                        onTap: () => context
                            .push(AppRoutes.projectDetailsPath(project.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first project to start tracking it here.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCreate,
              child: const Text('Create your first project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchesState extends StatelessWidget {
  final VoidCallback onClearFilters;

  const _NoMatchesState({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No projects match your search or filters.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
