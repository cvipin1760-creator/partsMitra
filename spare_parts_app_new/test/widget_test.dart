// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify athat the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spare_parts_app/main.dart';

void main() {
  testWidgets('App basic load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap it in a try-catch because it might require providers
    // but we just want to see if it pumps.
    await tester.pumpWidget(const MyApp());

    // Basic verification that the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
