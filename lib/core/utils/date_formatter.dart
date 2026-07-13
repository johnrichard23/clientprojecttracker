import 'package:intl/intl.dart';

/// Consistent date display across every screen. See
/// docs/system_requirements.md, Section 2.1 (e.g. `Jul 20, 2026`).
abstract final class DateFormatter {
  static final _short = DateFormat('MMM d, yyyy');

  static String short(DateTime date) => _short.format(date);
}
