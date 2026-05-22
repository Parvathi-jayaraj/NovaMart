import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:novamart/main.dart';

void main() {
  testWidgets('NovaMart app loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NovaMartApp()); // ← changed MyApp to NovaMartApp
  });
}