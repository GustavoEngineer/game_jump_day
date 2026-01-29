import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/blue_cube.dart';
import 'components/platform.dart';
import 'components/projectile.dart';
import 'components/finish_line.dart';
import 'components/star.dart';

class JumpDayGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final int initialLevel;
  BlueCube? cube;

  // World scrolling speed (pixels per second)
  final double worldScrollSpeed = 80.0;
  // Target Y position for the player on screen
  double _playerTargetY = 0.0;
  // Scroll threshold - world starts moving when player goes above this Y coordinate
  double _scrollThreshold = 0.0;
  // Track the highest point reached to enable continuous scrolling
  double _highestYReached = double.infinity;

  JumpDayGame({required this.initialLevel});

  @override
  Color backgroundColor() => const Color(0xFF111111); // Industrial Dark

  Future<void> levelCompleted(int stars) async {
    final prefs = await SharedPreferences.getInstance();

    // Save stars obtained (only if better than previous)
    final currentStars = prefs.getInt('level_${initialLevel}_stars') ?? 0;
    if (stars > currentStars) {
      await prefs.setInt('level_${initialLevel}_stars', stars);
    }

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
    // Configure camera to center the world/game
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    // Player will stay in lower third of screen (better visibility ahead)
    _playerTargetY = size.y * 0.7;
    // Set scroll threshold: world starts scrolling when player reaches 50% of screen height
    _scrollThreshold = size.y * 0.5;

    await _startLevel();
  }

  Future<void> _startLevel() async {
    // Reset highest Y reached
    _highestYReached = double.infinity;

    // Remove only game entities, leaving engine components intact
    world.children.whereType<Platform>().forEach((c) => c.removeFromParent());
    world.children.whereType<BlueCube>().forEach((c) => c.removeFromParent());
    world.children.whereType<FinishLine>().forEach((c) => c.removeFromParent());
    world.children.whereType<Star>().forEach((c) => c.removeFromParent());
    children.whereType<TimerComponent>().forEach((c) => c.removeFromParent());
    children
        .whereType<ParticleSystemComponent>()
        .forEach((c) => c.removeFromParent());
    children.whereType<Projectile>().forEach((c) => c.removeFromParent());

    // Game logic: generate platforms until we reach a vertical target height
    final double targetHeight = 5000.0; // Generate a level of 5000px tall
    final random = Random();

    if (initialLevel == 1) {
      double currentY = size.y - 120;
      bool leftSide = true;
      while (currentY > size.y - targetHeight) {
        final platformWidth = 100.0;
        // Position platforms closer to center for easier jumps
        final xPos = leftSide
            ? size.x * 0.3 - platformWidth / 2 // Left side at 30%
            : size.x * 0.7 - platformWidth / 2; // Right side at 70%
        world.add(Platform(
            position: Vector2(xPos, currentY),
            size: Vector2(platformWidth, 20),
            isMoving: false,
            isBreakable: false));
        currentY -= 110;
        leftSide = !leftSide;
      }

      // Add 3 stars strategically placed (easy level)
      // Star 1: Lower third (easy)
      world.add(
          Star(position: Vector2(size.x / 2, size.y - targetHeight * 0.25)));
      // Star 2: Middle third (medium)
      world.add(
          Star(position: Vector2(size.x * 0.3, size.y - targetHeight * 0.5)));
      // Star 3: Upper third (hard)
      world.add(
          Star(position: Vector2(size.x * 0.7, size.y - targetHeight * 0.8)));

      cube = BlueCube();
      await world.add(cube!);
    } else if (initialLevel == 2) {
      double currentY = size.y - 120;
      int index = 0;
      while (currentY > size.y - targetHeight) {
        double xPos = random.nextDouble() * (size.x - 150) + 25;
        double width = random.nextDouble() * 60 + 60;

        world.add(Platform(
            position: Vector2(xPos, currentY),
            size: Vector2(width, 20),
            isBreakable: (index % 2 != 0),
            explodeTime: 2.0));
        currentY -= 120;
        index++;
      }

      // Add 3 stars strategically placed (medium difficulty with breakable platforms)
      // Star 1: Lower third (easy)
      world.add(
          Star(position: Vector2(size.x * 0.4, size.y - targetHeight * 0.3)));
      // Star 2: Middle third (on/near breakable platform)
      world.add(
          Star(position: Vector2(size.x * 0.6, size.y - targetHeight * 0.55)));
      // Star 3: Upper third (challenging)
      world.add(
          Star(position: Vector2(size.x * 0.35, size.y - targetHeight * 0.85)));

      cube = BlueCube();
      await world.add(cube!);
    } else if (initialLevel == 3) {
      double currentY = size.y - 120;
      while (currentY > size.y - targetHeight) {
        double xPos = random.nextDouble() * (size.x - 150) + 25;
        double width = random.nextDouble() * 90 + 50;

        world.add(Platform(
            position: Vector2(xPos, currentY),
            size: Vector2(width, 20),
            isMoving: true,
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

      // Add 3 stars strategically placed (hard difficulty with moving platforms and projectiles)
      // Star 1: Lower third (moderate)
      world.add(
          Star(position: Vector2(size.x * 0.25, size.y - targetHeight * 0.28)));
      // Star 2: Middle third (risky - near projectile spawn area)
      world.add(
          Star(position: Vector2(size.x * 0.65, size.y - targetHeight * 0.5)));
      // Star 3: Upper third (very challenging)
      world.add(
          Star(position: Vector2(size.x * 0.45, size.y - targetHeight * 0.9)));

      cube = BlueCube();
      await world.add(cube!);
    }

    // Add a visible FinishLine at the top of the generated area
    world.add(FinishLine(
        position: Vector2(0, size.y - targetHeight),
        size: Vector2(size.x, 10)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the world downward only after player passes the scroll threshold
    if (cube != null && cube!.hasLeftGround) {
      // Track the highest point the player has reached
      if (cube!.y < _highestYReached) {
        _highestYReached = cube!.y;
      }

      // Only start scrolling if player has crossed the threshold
      // and is currently above the target position
      final bool hasPassedThreshold = _highestYReached < _scrollThreshold;
      final bool isAboveTarget = cube!.y < _playerTargetY;

      if (hasPassedThreshold && isAboveTarget) {
        final scrollAmount = worldScrollSpeed * dt;

        // Move all world objects down
        for (final platform in world.children.whereType<Platform>()) {
          platform.y += scrollAmount;
          // Remove platforms that are way below screen
          if (platform.y > size.y + 100) {
            platform.removeFromParent();
          }
        }

        for (final star in world.children.whereType<Star>()) {
          star.y += scrollAmount;
        }

        for (final finishLine in world.children.whereType<FinishLine>()) {
          finishLine.y += scrollAmount;
        }

        for (final projectile in children.whereType<Projectile>()) {
          projectile.y += scrollAmount;
        }

        // Gently push player back to target Y position
        final diff = _playerTargetY - cube!.y;
        cube!.y += diff * 0.02; // Gentle push
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (initialLevel >= 1 && initialLevel <= 3) {
      cube?.jump();
    }
  }
}
