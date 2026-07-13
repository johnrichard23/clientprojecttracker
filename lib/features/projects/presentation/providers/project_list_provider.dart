import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';

/// Fetches and holds the full, unfiltered project list. Search/filter state
/// is deliberately kept out of this notifier - see docs/constitution.md,
/// Section 8 (no god-notifiers holding unrelated state) - and lives in
/// [ProjectFilterNotifier] below instead.
class ProjectListNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() => _fetch();

  Future<List<Project>> _fetch() async {
    final result = await ref.read(getProjectsProvider)();
    return result.match((failure) => throw failure, (projects) => projects);
  }

  /// Re-runs the fetch, e.g. for pull-to-refresh. Keeps the previous data
  /// visible (via [AsyncValue.copyWithPrevious]) while the new fetch is in
  /// flight, per docs/system_requirements.md, Section 2.1.
  Future<void> refresh() async {
    state = const AsyncValue<List<Project>>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetch);
  }
}

final projectListProvider =
    AsyncNotifierProvider<ProjectListNotifier, List<Project>>(
  ProjectListNotifier.new,
);

/// Search text and status/priority filter state for the Project List screen.
/// See docs/system_requirements.md, Section 2.1 (search + filter chips).
class ProjectListFilter {
  final String searchText;
  final ProjectStatus? status;
  final ProjectPriority? priority;

  const ProjectListFilter({
    this.searchText = '',
    this.status,
    this.priority,
  });

  bool get isEmpty => searchText.isEmpty && status == null && priority == null;

  ProjectListFilter copyWith({
    String? searchText,
    ProjectStatus? status,
    bool clearStatus = false,
    ProjectPriority? priority,
    bool clearPriority = false,
  }) {
    return ProjectListFilter(
      searchText: searchText ?? this.searchText,
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectListFilter &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText &&
          status == other.status &&
          priority == other.priority;

  @override
  int get hashCode => Object.hash(searchText, status, priority);
}

/// Holds the current search/filter selection and persists the last-used
/// value via `shared_preferences`, so it survives an app restart. See
/// docs/architecture.md, Section 10 (State Persistence).
class ProjectFilterNotifier extends Notifier<ProjectListFilter> {
  static const _searchTextKey = 'project_filter_search_text';
  static const _statusKey = 'project_filter_status';
  static const _priorityKey = 'project_filter_priority';

  @override
  ProjectListFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final statusName = prefs.getString(_statusKey);
    final priorityName = prefs.getString(_priorityKey);

    return ProjectListFilter(
      searchText: prefs.getString(_searchTextKey) ?? '',
      status:
          statusName == null ? null : ProjectStatus.values.byName(statusName),
      priority: priorityName == null
          ? null
          : ProjectPriority.values.byName(priorityName),
    );
  }

  void setSearchText(String searchText) {
    state = state.copyWith(searchText: searchText);
    _persist();
  }

  void setStatusFilter(ProjectStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
    _persist();
  }

  void setPriorityFilter(ProjectPriority? priority) {
    state = state.copyWith(priority: priority, clearPriority: priority == null);
    _persist();
  }

  void clearFilters() {
    state = const ProjectListFilter();
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_searchTextKey, state.searchText);

    final status = state.status;
    if (status == null) {
      prefs.remove(_statusKey);
    } else {
      prefs.setString(_statusKey, status.name);
    }

    final priority = state.priority;
    if (priority == null) {
      prefs.remove(_priorityKey);
    } else {
      prefs.setString(_priorityKey, priority.name);
    }
  }
}

final projectFilterProvider =
    NotifierProvider<ProjectFilterNotifier, ProjectListFilter>(
  ProjectFilterNotifier.new,
);

/// The project list with search + status/priority filters applied. A plain
/// computed [Provider] rather than its own notifier, since it holds no state
/// of its own - it derives from [projectListProvider] and
/// [projectFilterProvider].
final filteredProjectListProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projectsAsync = ref.watch(projectListProvider);
  final filter = ref.watch(projectFilterProvider);

  return projectsAsync.whenData((projects) {
    final query = filter.searchText.trim().toLowerCase();

    return projects.where((project) {
      final matchesSearch = query.isEmpty ||
          project.clientName.toLowerCase().contains(query) ||
          project.projectName.toLowerCase().contains(query);
      final matchesStatus =
          filter.status == null || project.status == filter.status;
      final matchesPriority =
          filter.priority == null || project.priority == filter.priority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  });
});
