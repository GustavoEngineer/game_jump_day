import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/blue_cube.dart';
import 'components/platform.dart';
import 'components/projectile.dart';

class JumpDayGame extends FlameGame with TapCallbacks {
  final int initialLevel;
  BlueCube? cube;

  JumpDayGame({required this.initialLevel});

  @override
  Color backgroundColor() => const Color(0xFF111111); // Industrial Dark

  Future<void> levelCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    if (initialLevel == 1) {
      await prefs.setBool('level_2_unlocked', true);
      await prefs.setBool('level_1_completed', true);
    } else if (initialLevel == 2) {
      await prefs.setBool('level_3_unlocked', true);
      await prefs.setBool('level_2_completed', true);
    } else if (initialLevel == 3) {
      await prefs.setBool('level_3_completed', true);
    }
    overlays.add('WinMenu');
    pauseEngine();
  }

  void gameOver() {
    overlays.add('GameOverMenu');
    pauseEngine();
  }

  void resetLevel() {
    overlays.remove('GameOverMenu');
    overlays.remove('WinMenu');
    resumeEngine();
    _startLevel();
  }

  @override
  Future<void> onLoad() async {
    _startLevel();
  }

  void _startLevel() {
    // Remove only game entities, leaving engine components intact
    children.whereType<Platform>().forEach((c) => c.removeFromParent());
    children.whereType<BlueCube>().forEach((c) => c.removeFromParent());
    children.whereType<TimerComponent>().forEach((c) => c.removeFromParent());
    children
        .whereType<ParticleSystemComponent>()
        .forEach((c) => c.removeFromParent());
    children.whereType<Projectile>().forEach((c) => c.removeFromParent());

    // Game logic
    if (initialLevel == 1) {
      // Level 1 Platforms
      double currentY = size.y - 120;
      bool leftSide = true;
      for (int i = 0; i < 15; i++) {
        add(Platform(
            position: Vector2(leftSide ? 50 : size.x - 150, currentY),
            size: Vector2(100, 20)));
        currentY -= 110;
        leftSide = !leftSide;
      }
      cube = BlueCube();
      add(cube!);
    } else if (initialLevel == 2) {
      // Level 2 Platforms (Randomized Layout)
      final random = Random();
      double currentY = size.y - 120;
      for (int i = 0; i < 20; i++) {
        // Random X Position (keeping padding)
        double xPos = random.nextDouble() * (size.x - 150) + 25;
        // Random Width (60 to 120)
        double width = random.nextDouble() * 60 + 60;

        add(Platform(
            position: Vector2(xPos, currentY),
            size: Vector2(width, 20), // Random size
            isBreakable: (i % 2 != 0), // Every odd platform breaks
            explodeTime: 2.0 // Faster explosion for Level 2
            ));
        currentY -= 120; // Slightly larger gap
      }
      cube = BlueCube();
      add(cube!);
    } else if (initialLevel == 3) {
      // Level 3 Platforms (Redesigned: Moving + Projectiles)
      final random = Random();
      double currentY = size.y - 120;
      for (int i = 0; i < 30; i++) {
        // Random X Position
        double xPos = random.nextDouble() * (size.x - 150) + 25;
        // Random Width (50 to 140)
        double width = random.nextDouble() * 90 + 50;

        add(Platform(
            position: Vector2(xPos, currentY),
            size: Vector2(width, 20), // Random size
            isMoving: true, // Moving platforms
            isBreakable: false));
        currentY -= 120;
      }

      // Spawn Projectiles every 5 seconds
      add(TimerComponent(
          period: 5,
          repeat: true,
          onTick: () {
            double projectileX = random.nextDouble() * (size.x - 20);
            add(Projectile(position: Vector2(projectileX, -50)));
          }));

      cube = BlueCube();
      add(cube!);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (initialLevel >= 1 && initialLevel <= 3) {
      cube?.jump();
    }
  }
}
