/// Result of validating a project form. `fieldErrors` maps a field name
/// (matching the form field, e.g. 'clientName') to a human-readable message.
class ProjectValidationResult {
  final Map<String, String> fieldErrors;

  const ProjectValidationResult(this.fieldErrors);

  bool get isValid => fieldErrors.isEmpty;
}

/// Validates project form input before it's turned into a [Project] entity
/// and handed to a use case. Pure Dart, no Flutter dependency - see
/// docs/constitution.md, Section 10 (Testing Mandate).
class ProjectValidator {
  static const _maxDescriptionLength = 2000;

  ProjectValidationResult validate({
    required String clientName,
    required String projectName,
    required String description,
    required DateTime startDate,
    required DateTime dueDate,
  }) {
    final errors = <String, String>{};

    if (clientName.trim().isEmpty) {
      errors['clientName'] = 'Client name is required.';
    }

    if (projectName.trim().isEmpty) {
      errors['projectName'] = 'Project name is required.';
    }

    if (description.length > _maxDescriptionLength) {
      errors['description'] =
          'Description must be $_maxDescriptionLength characters or fewer.';
    }

    if (dueDate.isBefore(startDate)) {
      errors['dueDate'] = 'Due date cannot be before the start date.';
    }

    return ProjectValidationResult(errors);
  }
}
