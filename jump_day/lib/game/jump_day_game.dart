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
import '../models/skin_selection_service.dart';
import '../models/playable_character.dart';

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
    // Limpieza y declaración única de variables
    _highestYReached = 0; // Highest Y (climbing up is lower Y)
    _cameraHighestY = 0;
    camera.viewfinder.position = Vector2.zero();
    
    world.children.whereType<Platform>().forEach((c) => c.removeFromParent());
    world.children.whereType<BlueCube>().forEach((c) => c.removeFromParent());
    world.children.whereType<FinishLine>().forEach((c) => c.removeFromParent());
    world.children.whereType<Star>().forEach((c) => c.removeFromParent());
    children.whereType<TimerComponent>().forEach((c) => c.removeFromParent());
    children.whereType<ParticleSystemComponent>().forEach((c) => c.removeFromParent());
    children.whereType<Projectile>().forEach((c) => c.removeFromParent());
    final selectedCharacter = await SkinSelectionService.loadSelectedSkin();
    final double targetHeight = 5000.0;
    final random = Random();

    if (initialLevel == 0) {
      // Infinite Mode Initialization
      _lastGeneratedY = size.y - 120;
      double currentY = size.y - 120;
      
      // Start with some initial platforms
      for (int i = 0; i < 10; i++) {
        double xPos = random.nextDouble() * (size.x - 150) + 25;
        world.add(Platform(
          position: Vector2(xPos, currentY),
          size: Vector2(100, 20),
          isBreakable: false,
        ));
        currentY -= 120;
      }
      _lastGeneratedY = currentY;
      
      cube = BlueCube(character: selectedCharacter);
      await world.add(cube!);
    } else if (initialLevel == 1) {
      double currentY = size.y - 120;
      bool leftSide = true;
      while (currentY > size.y - targetHeight) {
        final platformWidth = 100.0;
        final xPos = leftSide
            ? size.x * 0.3 - platformWidth / 2
            : size.x * 0.7 - platformWidth / 2;
        world.add(Platform(
            position: Vector2(xPos, currentY),
            size: Vector2(platformWidth, 20),
            isMoving: false,
            isBreakable: false));
        currentY -= 110;
        leftSide = !leftSide;
      }
      world.add(Star(position: Vector2(size.x / 2, size.y - targetHeight * 0.25)));
      world.add(Star(position: Vector2(size.x * 0.3, size.y - targetHeight * 0.5)));
      world.add(Star(position: Vector2(size.x * 0.7, size.y - targetHeight * 0.8)));
      cube = BlueCube(character: selectedCharacter);
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
      world.add(Star(position: Vector2(size.x * 0.4, size.y - targetHeight * 0.3)));
      world.add(Star(position: Vector2(size.x * 0.6, size.y - targetHeight * 0.55)));
      world.add(Star(position: Vector2(size.x * 0.35, size.y - targetHeight * 0.85)));
      cube = BlueCube(character: selectedCharacter);
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
      add(TimerComponent(
          period: 5,
          repeat: true,
          onTick: () {
            double projectileX = random.nextDouble() * (size.x - 20);
            add(Projectile(position: Vector2(projectileX, -50)));
          }));
      world.add(Star(position: Vector2(size.x * 0.25, size.y - targetHeight * 0.28)));
      world.add(Star(position: Vector2(size.x * 0.65, size.y - targetHeight * 0.5)));
      world.add(Star(position: Vector2(size.x * 0.45, size.y - targetHeight * 0.9)));
      cube = BlueCube(character: selectedCharacter);
      await world.add(cube!);
    }

    if (initialLevel != 0) {
      world.add(FinishLine(
          position: Vector2(0, size.y - targetHeight),
          size: Vector2(size.x, 10)));
    }
  }
  @override
  void update(double dt) {
    super.update(dt);
    
    if (cube != null) {
      // Camera follow logic
      final playerY = cube!.y;
      
      // We only move the camera up, never down
      // Let's make it follow the player such that player is at 70% of screen height
      double desiredCameraY = playerY - size.y * 0.7;
      
      // But camera Y should not go below _highestYReached camera position (to prevent falling down)
      // Actually simpler: track the highest point the camera has reached.
      if (desiredCameraY < _cameraHighestY) {
        _cameraHighestY = desiredCameraY;
      }

      // Smoothly move camera towards the highest desired position
      // For now, let's keep it locked to avoid lag in a fast game
      camera.viewfinder.position = Vector2(0, _cameraHighestY);
    }

    // Infinite mode platform generation
    if (initialLevel == 0 && cube != null) {
      _checkAndGenerateInfinitePlatforms();
    }
  }

  double _cameraHighestY = 0;
  double _lastGeneratedY = 0;

  void _checkAndGenerateInfinitePlatforms() {
    final viewportTop = camera.viewfinder.position.y;
    final random = Random();
    
    while (_lastGeneratedY > viewportTop - size.y) {
      double xPos = random.nextDouble() * (size.x - 100) + 20;
      double width = random.nextDouble() * 60 + 60;
      bool isBreakable = random.nextDouble() > 0.8;
      bool isMoving = random.nextDouble() > 0.9;

      world.add(Platform(
        position: Vector2(xPos, _lastGeneratedY),
        size: Vector2(width, 20),
        isBreakable: isBreakable,
        isMoving: isMoving,
        explodeTime: 1.5,
      ));

      _lastGeneratedY -= 120 + random.nextDouble() * 40;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    cube?.jump();
  }
}
