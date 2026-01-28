import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class Projectile extends PositionComponent with HasGameRef<JumpDayGame> {
  final double speed = 300.0;

  Projectile({required Vector2 position})
      : super(position: position, size: Vector2.all(20), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    y += speed * dt;

    if (y > gameRef.size.y) {
      removeFromParent();
    }

    // Check collision with Player
    if (gameRef.cube != null) {
      final cube = gameRef.cube!;
      if (checkCollision(cube)) {
        gameRef.gameOver();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(width / 2, height / 2), width / 2,
        Paint()..color = const Color(0xFFFF4400));
  }

  bool checkCollision(PositionComponent other) {
    // Simple AABB collision (Circle fits in square box)
    return x < other.x + other.width &&
        x + width > other.x &&
        y < other.y + other.height &&
        y + height > other.y;
  }
}
