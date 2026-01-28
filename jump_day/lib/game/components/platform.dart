import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../jump_day_game.dart';

class Platform extends PositionComponent with HasGameRef<JumpDayGame> {
  final bool isBreakable;
  final bool isMoving;
  final double explodeTime;
  bool _isBreaking = false;
  double _moveSpeed = 100.0;
  int _direction = 1;

  Platform(
      {required Vector2 position,
      required Vector2 size,
      this.isBreakable = false,
      this.isMoving = false,
      this.explodeTime = 3.0})
      : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    super.update(dt);
    if (isMoving) {
      x += _moveSpeed * _direction * dt;
      // Bounce off walls
      if (x <= 0) {
        _direction = 1;
      } else if (x + width >= gameRef.size.x) {
        _direction = -1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final color = _isBreaking ? Colors.redAccent : const Color(0xFF0D3B3C);
    canvas.drawRect(size.toRect(), Paint()..color = color);
  }

  void onLanded() {
    if (isBreakable && !_isBreaking) {
      _isBreaking = true;
      // Start break timer using Flame TimerComponent
      add(TimerComponent(
        period: explodeTime,
        removeOnFinish: true,
        onTick: () {
          _explode();
          removeFromParent();
        },
      ));
    }
  }

  void _explode() {
    // 1. Visual Explosion
    gameRef.add(
      ParticleSystemComponent(
        position: center,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(
              (Random().nextDouble() - 0.5) * 300,
              (Random().nextDouble() - 0.5) * 300,
            ),
            child: CircleParticle(
              radius: 4,
              paint: Paint()..color = Colors.orange,
            ),
          ),
        ),
      ),
    );

    // 2. Knockback
    final cube = gameRef.cube;
    if (cube != null) {
      double distance = center.distanceTo(cube.center);
      if (distance < 150) {
        // Launch player!
        cube.velocityY = -1500; // Sky high

        // Push away horizontally
        double dirX = cube.center.x < center.x ? -1 : 1;
        cube.velocityX = dirX * 1000;
      }
    }
  }
}
