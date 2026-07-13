import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ClientProjectTrackerApp(),
    ),
  );
}
