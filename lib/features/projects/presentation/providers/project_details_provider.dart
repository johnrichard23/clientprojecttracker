import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';

/// Fetches a single project by id and exposes delete as an action. See
/// docs/system_requirements.md, Section 2.4.
class ProjectDetailsNotifier extends FamilyAsyncNotifier<Project, String> {
  @override
  Future<Project> build(String id) => _fetch(id);

  Future<Project> _fetch(String id) async {
    final result = await ref.read(getProjectByIdProvider)(id);
    return result.match((failure) => throw failure, (project) => project);
  }

  /// Re-runs the fetch, e.g. after the user retries a failed load.
  Future<void> refresh() async {
    state = const AsyncValue<Project>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  /// Deletes this project. The immediate outcome is returned directly so
  /// the screen can show a confirmation toast / navigate away on success,
  /// or show an inline error on failure - it isn't folded into [state].
  ///
  /// [state] itself is refreshed by re-fetching afterwards: on success this
  /// naturally surfaces as a [NotFoundFailure] (the project is gone), which
  /// the details screen already renders as its "not found" error state per
  /// docs/system_requirements.md, Section 2.4. On failure, the re-fetch just
  /// confirms the project is still there, so [state] is left as-is.
  Future<Either<Failure, Unit>> delete() async {
    final id = arg;
    final result = await ref.read(deleteProjectProvider)(id);
    state = await AsyncValue.guard(() => _fetch(id));
    return result;
  }
}

final projectDetailsProvider =
    AsyncNotifierProvider.family<ProjectDetailsNotifier, Project, String>(
  ProjectDetailsNotifier.new,
);
