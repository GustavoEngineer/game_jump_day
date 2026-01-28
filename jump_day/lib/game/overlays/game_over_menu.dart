import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class GameOverMenu extends StatelessWidget {
  final JumpDayGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Game Over",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.resetLevel();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Try Again",
                  style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Back to Map
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("Back to Map",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
