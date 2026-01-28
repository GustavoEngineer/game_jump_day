import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class WinMenu extends StatelessWidget {
  final JumpDayGame game;

  const WinMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Level Complete!",
                style: TextStyle(color: Colors.white, fontSize: 30)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close GameWidget, return to Map
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text("Back to Map",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
