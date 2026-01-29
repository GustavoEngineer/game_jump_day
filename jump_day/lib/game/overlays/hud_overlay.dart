import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class HudOverlay extends StatelessWidget {
  final JumpDayGame game;

  const HudOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Star counter at the top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.yellow.withOpacity(0.5), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star icon
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 28,
                    shadows: [
                      Shadow(
                        color: Colors.orange,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Star count
                  StreamBuilder<int>(
                    stream: game.cube != null
                        ? Stream.periodic(const Duration(milliseconds: 100),
                            (_) => game.cube!.starsCollected)
                        : Stream.value(0),
                    builder: (context, snapshot) {
                      final stars = snapshot.data ?? 0;
                      return Text(
                        '$stars / 3',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Level indicator at the bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Text(
                'Level ${game.initialLevel}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
