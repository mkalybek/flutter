import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_nights/main.dart';

void main() {
  testWidgets('theme chips follow MyApp state', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(
      find.text('Twilight Imperium Marathon: Full Galaxy Conquest Until Dawn!'),
      findsOneWidget,
    );
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dark'));
    await tester.pumpAndSettle();
    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Dark'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('save pops a dirty form with the new night', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Codenames Party'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Codenames Night',
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Codenames Night'), findsWidgets);
    expect(find.text('Discard changes?'), findsNothing);
  });
}
