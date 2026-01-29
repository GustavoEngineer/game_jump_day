import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class Star extends PositionComponent
    with HasGameRef<JumpDayGame>, CollisionCallbacks {
  double rotationAngle = 0;
  bool collected = false;
  double pulseTime = 0;

  Star({required super.position})
      : super(size: Vector2.all(30), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add a circular hitbox for collision detection
    add(CircleHitbox(
      radius: size.x / 2,
      collisionType: CollisionType.passive,
    ));

    // Add floating effect
    add(MoveEffect.by(
      Vector2(0, -10),
      EffectController(
        duration: 1.5,
        infinite: true,
        alternate: true,
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Rotate 360° continuously (one full rotation every 2 seconds)
    rotationAngle += pi * dt; // π radians per second = 180° per second
    if (rotationAngle >= 2 * pi) {
      rotationAngle -= 2 * pi;
    }

    pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (collected) return;

    canvas.save();
    // Move to center for rotation
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotationAngle);

    // Draw pixel art star (5-pointed star)
    final paint = Paint()
      ..color = const Color(0xFFFFD700) // Gold color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Create a 5-pointed star path
    final path = Path();
    final radius = size.x / 2 - 2; // Outer radius
    final innerRadius = radius * 0.4; // Inner radius

    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2; // Start from top
      final r = i % 2 == 0 ? radius : innerRadius;
      final x = cos(angle) * r;
      final y = sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw star with border for better visibility
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    canvas.restore();

    // Draw glowing halo effect
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 + 5 + sin(pulseTime * 3) * 3,
      Paint()
        ..color = Colors.yellow.withOpacity(0.2 + sin(pulseTime * 3) * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void collect() {
    if (!collected) {
      collected = true;

      // Create collection particles
      final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, -200),
            speed: Vector2(
              (Random().nextDouble() - 0.5) * 200,
              (Random().nextDouble() - 0.5) * 200,
            ),
            position: position.clone(),
            child: CircleParticle(
              radius: 2 + Random().nextDouble() * 2,
              paint: Paint()..color = Colors.yellow.withOpacity(0.8),
            ),
          ),
        ),
        position: Vector2.zero(),
      );

      gameRef.add(particleComponent);
      removeFromParent();
    }
  }
}
