import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:binayak_pharmacy/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds and shows the MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
