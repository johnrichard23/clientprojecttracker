import 'package:client_project_tracker/core/errors/failures.dart';

/// The single place a [Failure] becomes user-facing text. Deliberately does
/// not echo back [Failure.message] - that field may carry raw
/// exception/debug detail (e.g. a Drift exception string) that must never
/// reach the UI. See docs/constitution.md, Section 9 and
/// docs/architecture.md, Section 7.
extension FailureMessage on Failure {
  String toUserMessage() {
    return switch (this) {
      ValidationFailure() => 'Please check the highlighted fields and try again.',
      DatabaseFailure() =>
        'Something went wrong saving your data. Please try again.',
      NetworkFailure() =>
        'No internet connection. Please check your network and try again.',
      NotFoundFailure() =>
        'This project could not be found. It may have already been deleted.',
      UnknownFailure() => 'Something went wrong. Please try again.',
    };
  }
}
