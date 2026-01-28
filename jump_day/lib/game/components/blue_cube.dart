import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'platform.dart';
import '../jump_day_game.dart';

class BlueCube extends PositionComponent with HasGameRef<JumpDayGame> {
  double speed = 250.0; // Reduced speed
  int direction = 1;

  double velocityX = 0; // External horizontal force
  double velocityY = 0; // Vertical velocity
  final double gravity = 2600.0; // Stronger gravity for faster fall
  final double jumpForce = -1050.0; // Tuned jump height
  bool hasLeftGround = false; // Track if player started climbing

  BlueCube() : super(size: Vector2.all(50), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = Vector2(gameRef.size.x / 2, gameRef.size.y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFF9900));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal Movement (Auto-run + External Force)
    x += (speed * direction + velocityX) * dt;

    // Apply friction to external force
    velocityX *= 0.9; // Fast decay
    if (velocityX.abs() < 10) velocityX = 0;

    // Bounce check
    if (x >= gameRef.size.x - width / 2) {
      direction = -1;
    } else if (x <= width / 2) {
      direction = 1;
    }

    // Vertical Physics
    velocityY += gravity * dt;
    double dy = velocityY * dt;
    double oldY = y;
    y += dy;

    // Check if left ground
    if (y < gameRef.size.y - 100) {
      hasLeftGround = true;
    }

    // Platform Collisions (One-way)
    // Only check if falling
    if (velocityY > 0) {
      final platforms = gameRef.children.whereType<Platform>();
      for (final platform in platforms) {
        // Check standard AABB collision
        bool currentOverlap = x + width > platform.x &&
            x < platform.x + platform.width &&
            y > platform.y &&
            y - height < platform.y + platform.height;

        // One-way check: Must have been above previous frame
        bool wasAbove =
            oldY <= platform.y; // Using bottom anchor behavior for BlueCube?
        // Wait, BlueCube anchor is bottomCenter.
        // So 'y' is the bottom of the cube.
        // Platform anchor is topLeft.
        // So comparison: oldY <= platform.y means bottom was above platform top.

        // Let's re-verify anchor. BlueCube is bottomCenter.
        // y is exactly the bottom edge.
        // platform.y is top edge.

        if (currentOverlap && wasAbove) {
          y = platform.y;
          velocityY = 0;
          platform.onLanded();
          break; // Landed
        }
      }
    }

    // Ground Collision
    if (y >= gameRef.size.y) {
      y = gameRef.size.y;

      if (hasLeftGround) {
        gameRef.gameOver();
      }

      if (velocityY > 0) {
        velocityY = 0;
      }
    }
    // Check Win Condition (Top of level)
    if (y < -50) {
      gameRef.levelCompleted();
    }
  }

  void jump() {
    bool onGround = y >= gameRef.size.y;

    // Check if near wall (allow wall jump)
    bool onWall = x <= width / 2 + 10 || x >= gameRef.size.x - width / 2 - 10;

    // Check if on platform
    bool onPlatform = false;
    final platforms = gameRef.children.whereType<Platform>();
    for (final platform in platforms) {
      // Add epsilon tolerance for Y-axis check (sensitivity fix)
      if ((y - platform.y).abs() < 5 &&
          x + width / 2 > platform.x &&
          x - width / 2 < platform.x + platform.width) {
        onPlatform = true;
        break;
      }
    }

    if (onGround || onPlatform || onWall) {
      velocityY = jumpForce;
    }
  }
}
