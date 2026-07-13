import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route paths, defined once so navigation calls are compile-checked instead
/// of built from raw strings scattered across the app. See
/// docs/architecture.md, Section 9.
abstract final class AppRoutes {
  static const projectList = '/';
  static const projectCreate = '/projects/new';
  static const projectDetails = '/projects/:id';
  static const projectEdit = '/projects/:id/edit';

  static String projectDetailsPath(String id) => '/projects/$id';
  static String projectEditPath(String id) => '/projects/$id/edit';
}

/// TODO: wire real screens in as they're built (ProjectListScreen,
/// ProjectFormScreen, ProjectDetailsScreen). This placeholder keeps the app
/// runnable from the very first commit.
final appRouter = GoRouter(
  initialLocation: AppRoutes.projectList,
  routes: [
    GoRoute(
      path: AppRoutes.projectList,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Project List',
      ),
    ),
    GoRoute(
      path: AppRoutes.projectCreate,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Create Project',
      ),
    ),
    GoRoute(
      path: AppRoutes.projectDetails,
      builder: (context, state) => _PlaceholderScreen(
        title: 'Project Details (${state.pathParameters['id']})',
      ),
    ),
    GoRoute(
      path: AppRoutes.projectEdit,
      builder: (context, state) => _PlaceholderScreen(
        title: 'Edit Project (${state.pathParameters['id']})',
      ),
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title screen - not built yet.')),
    );
  }
}
