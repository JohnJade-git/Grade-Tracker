// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grade_tracker/main.dart';

void main() {
  testWidgets('student can register', (WidgetTester tester) async {
    await tester.pumpWidget(const GradeTrackerApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jordan Lee');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'jordan@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'pass1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Hey, Jordan'), findsOneWidget);
  });

  testWidgets('student can log in and add a grade', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GradeTrackerApp());
    expect(find.text('grade garden'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'alex@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'pass1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Hey, alex'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);

    await tester.tap(find.byTooltip('Add a grade'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biology').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Lab practical');
    await tester.enterText(find.byType(TextFormField).at(1), '18');
    await tester.enterText(find.byType(TextFormField).at(2), '20');
    await tester.tap(find.text('Save grade'));
    await tester.pumpAndSettle();

    expect(find.text('88.1%'), findsOneWidget);
  });
}
