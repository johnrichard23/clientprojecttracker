import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/features/projects/presentation/providers/project_list_provider.dart';

/// Debounced search-by-name field for the Project List screen. See
/// docs/system_requirements.md, Section 2.1.
class ProjectSearchBar extends ConsumerStatefulWidget {
  const ProjectSearchBar({super.key});

  @override
  ConsumerState<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends ConsumerState<ProjectSearchBar> {
  static const _debounceDuration = Duration(milliseconds: 300);

  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(projectFilterProvider).searchText,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      ref.read(projectFilterProvider.notifier).setSearchText(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: const InputDecoration(
          hintText: 'Search by client or project name',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
