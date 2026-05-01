import 'package:flutter_test/flutter_test.dart';
import 'package:todoey_flutter/app/productivity_coach_app.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProductivityCoachApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
