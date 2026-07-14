import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:client_project_tracker/core/errors/failure_message.dart';
import 'package:client_project_tracker/core/errors/failures.dart';
import 'package:client_project_tracker/core/utils/date_formatter.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_priority.dart';
import 'package:client_project_tracker/features/projects/domain/entities/project_status.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_details_provider.dart';
import 'package:client_project_tracker/features/projects/presentation/providers/project_form_provider.dart';

/// Shared Create/Edit form. See docs/system_requirements.md, Sections 2.2
/// and 2.3, and docs/architecture.md (one screen, driven by [mode]).
class ProjectFormScreen extends ConsumerStatefulWidget {
  final ProjectFormMode mode;
  final String? projectId;

  const ProjectFormScreen.create({super.key})
      : mode = ProjectFormMode.create,
        projectId = null;

  const ProjectFormScreen.edit({super.key, required String this.projectId})
      : mode = ProjectFormMode.edit;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  late final TextEditingController _clientNameController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _descriptionController;

  ProjectStatus _status = ProjectStatus.planning;
  ProjectPriority _priority = ProjectPriority.medium;
  DateTime? _startDate;
  DateTime? _dueDate;
  Map<String, String> _localFieldErrors = {};
  bool _seededFromExisting = false;

  ProjectFormArgs get _args => widget.mode == ProjectFormMode.create
      ? const ProjectFormArgs.create()
      : ProjectFormArgs.edit(widget.projectId!);

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController();
    _projectNameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _seedFromExisting(Project project) {
    _clientNameController.text = project.clientName;
    _projectNameController.text = project.projectName;
    _descriptionController.text = project.description;
    _status = project.status;
    _priority = project.priority;
    _startDate = project.startDate;
    _dueDate = project.dueDate;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    final missing = <String, String>{};
    if (_startDate == null) missing['startDate'] = 'Start date is required.';
    if (_dueDate == null) missing['dueDate'] = 'Due date is required.';
    if (missing.isNotEmpty) {
      setState(() => _localFieldErrors = missing);
      return;
    }
    setState(() => _localFieldErrors = {});

    final notifier = ref.read(projectFormProvider(_args).notifier);
    await notifier.submit(
      clientName: _clientNameController.text,
      projectName: _projectNameController.text,
      description: _descriptionController.text,
      status: _status,
      priority: _priority,
      startDate: _startDate!,
      dueDate: _dueDate!,
    );

    if (!mounted) return;
    final state = ref.read(projectFormProvider(_args));
    if (state.hasValue && state.value != null) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == ProjectFormMode.edit && !_seededFromExisting) {
      final detailsAsync =
          ref.watch(projectDetailsProvider(widget.projectId!));

      return detailsAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Project')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Project')),
          body: Center(
            child: Text(
              error is Failure
                  ? error.toUserMessage()
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (project) {
          _seedFromExisting(project);
          _seededFromExisting = true;
          return _buildForm(context);
        },
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final formState = ref.watch(projectFormProvider(_args));
    final notifier = ref.read(projectFormProvider(_args).notifier);
    final fieldErrors = {..._localFieldErrors, ...notifier.fieldErrors};
    final isSubmitting = formState.isLoading;
    final nonValidationFailure =
        formState.error is Failure && formState.error is! ValidationFailure
            ? formState.error as Failure
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == ProjectFormMode.create
            ? 'Create Project'
            : 'Edit Project',),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (nonValidationFailure != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nonValidationFailure.toUserMessage(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: 'Client Name',
                errorText: fieldErrors['clientName'],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                errorText: fieldErrors['projectName'],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLength: 2000,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                errorText: fieldErrors['description'],
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProjectStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                for (final status in ProjectStatus.values)
                  DropdownMenuItem(value: status, child: Text(status.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProjectPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: [
                for (final priority in ProjectPriority.values)
                  DropdownMenuItem(
                      value: priority, child: Text(priority.label),),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(
                _startDate == null
                    ? 'Select a date'
                    : DateFormatter.short(_startDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
            ),
            if (fieldErrors['startDate'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  fieldErrors['startDate']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(
                _dueDate == null
                    ? 'Select a date'
                    : DateFormatter.short(_dueDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            if (fieldErrors['dueDate'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  fieldErrors['dueDate']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.mode == ProjectFormMode.create
                      ? 'Create Project'
                      : 'Save Changes',),
            ),
          ],
        ),
      ),
    );
  }
}
