import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/create_project.dart';
import 'package:client_project_tracker/features/projects/domain/usecases/update_project.dart';

enum ProjectFormMode { create, edit }

/// Which use case [ProjectFormNotifier] should call, and (for edit) which
/// existing project id to update. The Create and Edit screens share one
/// form UI and one notifier shape - see docs/system_requirements.md,
/// Section 2.3.
class ProjectFormArgs {
  final ProjectFormMode mode;
  final String? projectId;

  const ProjectFormArgs.create()
      : mode = ProjectFormMode.create,
        projectId = null;

  const ProjectFormArgs.edit(this.projectId) : mode = ProjectFormMode.edit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFormArgs &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          projectId == other.projectId;

  @override
  int get hashCode => Object.hash(mode, projectId);
}

/// Handles both Create and Edit submissions. Validation itself lives inside
/// the `CreateProject`/`UpdateProject` use cases (already unit tested there)
/// - this notifier's job is only to call the right one for the current mode
/// and surface the `Either` result as `AsyncValue`. See
/// docs/architecture.md, Section 6 (Data Flow Example).
class ProjectFormNotifier
    extends FamilyAsyncNotifier<Project?, ProjectFormArgs> {
  @override
  Future<Project?> build(ProjectFormArgs arg) async => null;

  /// Field-level messages from the last [ValidationFailure], if the last
  /// submission failed validation - empty otherwise. The form reads this to
  /// show inline errors next to each field, per
  /// docs/system_requirements.md, Section 2.2.
  Map<String, String> get fieldErrors {
    final error = state.error;
    return error is ValidationFailure ? error.fieldErrors : const {};
  }

  Future<void> submit({
    required String clientName,
    required String projectName,
    required String description,
    required ProjectStatus status,
    required ProjectPriority priority,
    required DateTime startDate,
    required DateTime dueDate,
  }) async {
    state = const AsyncValue<Project?>.loading().copyWithPrevious(state);

    final result = arg.mode == ProjectFormMode.create
        ? await ref.read(createProjectProvider)(CreateProjectParams(
            clientName: clientName,
            projectName: projectName,
            description: description,
            status: status,
            priority: priority,
            startDate: startDate,
            dueDate: dueDate,
          ))
        : await ref.read(updateProjectProvider)(UpdateProjectParams(
            id: arg.projectId!,
            clientName: clientName,
            projectName: projectName,
            description: description,
            status: status,
            priority: priority,
            startDate: startDate,
            dueDate: dueDate,
          ));

    state = result.match(
      (failure) => AsyncValue<Project?>.error(failure, StackTrace.current),
      (project) => AsyncValue<Project?>.data(project),
    );
  }
}

final projectFormProvider = AsyncNotifierProvider.family<ProjectFormNotifier,
    Project?, ProjectFormArgs>(
  ProjectFormNotifier.new,
);
