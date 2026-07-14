import 'package:go_router/go_router.dart';

import 'package:client_project_tracker/features/projects/presentation/screens/project_details_screen.dart';
import 'package:client_project_tracker/features/projects/presentation/screens/project_form_screen.dart';
import 'package:client_project_tracker/features/projects/presentation/screens/project_list_screen.dart';

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

final appRouter = GoRouter(
  initialLocation: AppRoutes.projectList,
  routes: [
    GoRoute(
      path: AppRoutes.projectList,
      builder: (context, state) => const ProjectListScreen(),
    ),
    GoRoute(
      path: AppRoutes.projectCreate,
      builder: (context, state) => const ProjectFormScreen.create(),
    ),
    GoRoute(
      path: AppRoutes.projectDetails,
      builder: (context, state) => ProjectDetailsScreen(
        projectId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.projectEdit,
      builder: (context, state) => ProjectFormScreen.edit(
        projectId: state.pathParameters['id']!,
      ),
    ),
  ],
);
