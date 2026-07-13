/// Base type for all typed failures returned across layer boundaries.
///
/// Use cases and repositories return Either<Failure, T> (fpdart) instead of
/// throwing, so callers can't forget to handle an error path.
/// See docs/constitution.md, Section 9.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// A form field or business rule failed validation before anything touched
/// storage (e.g. missing required field, due date before start date).
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
}

/// Something went wrong reading from or writing to local storage.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Reserved for the future remote data source (see architecture.md, Section 11).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// The requested project doesn't exist (e.g. deleted elsewhere, bad id).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Fallback for anything unexpected. Should be rare - most failures should
/// be categorized more specifically than this.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
