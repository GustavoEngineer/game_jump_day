import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jump_day/game/jump_day_game.dart';

void main() {
  testWidgets('Game widget loads', (WidgetTester tester) async {
    // Build our game and trigger a frame.
    await tester.pumpWidget(GameWidget(game: JumpDayGame(initialLevel: 1)));

    // Verify that the GameWidget is present.
    expect(find.byType(GameWidget<JumpDayGame>), findsOneWidget);
  });
}
