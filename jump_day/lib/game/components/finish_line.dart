import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class FinishLine extends PositionComponent
    with HasGameRef<JumpDayGame>, CollisionCallbacks {
  double animationTime = 0;
  bool playerCrossed = false;

  FinishLine({required Vector2 position, required Vector2 size})
      : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Passive rectangle hitbox occupying the finish area
    add(RectangleHitbox(collisionType: CollisionType.passive));

    // Add pulsing scale effect to make it more visible
    add(ScaleEffect.by(
      Vector2.all(1.05),
      EffectController(
        duration: 1.0,
        infinite: true,
        alternate: true,
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Animated checkered pattern (racing flag style)
    final int squares = 8;
    final double squareWidth = size.x / squares;
    final double squareHeight = size.y;

    // Animate the pattern by shifting colors
    final offset = (animationTime * 2) % 2;

    for (int i = 0; i < squares; i++) {
      final bool isEven = (i + offset.floor()) % 2 == 0;
      final color = isEven ? Colors.greenAccent : Colors.white;

      canvas.drawRect(
        Rect.fromLTWH(i * squareWidth, 0, squareWidth, squareHeight),
        Paint()..color = color,
      );
    }

    // Add glowing border effect
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color =
            Colors.yellowAccent.withOpacity(0.5 + sin(animationTime * 3) * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Draw "FINISH" text if player hasn't crossed yet
    if (!playerCrossed) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'FINISH',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.yellowAccent,
                blurRadius: 2 + sin(animationTime * 4) * 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2, -25),
      );
    }
  }

  void onPlayerCrossed() {
    playerCrossed = true;
  }
}
