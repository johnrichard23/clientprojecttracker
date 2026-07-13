import 'package:flutter_test/flutter_test.dart';

import 'package:client_project_tracker/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.short', () {
    test('formats a date as "MMM d, yyyy"', () {
      expect(DateFormatter.short(DateTime(2026, 7, 20)), 'Jul 20, 2026');
    });

    test('does not zero-pad single-digit days', () {
      expect(DateFormatter.short(DateTime(2026, 1, 5)), 'Jan 5, 2026');
    });
  });
}
