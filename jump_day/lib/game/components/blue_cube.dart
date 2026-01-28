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

  // Jump Mechanics Optimization
  final double kCoyoteTime = 0.15; // 150ms grace period after leaving ground
  final double kJumpBufferTime = 0.15; // 150ms buffer for early presses
  double coyoteTimer = 0;
  double jumpBufferTimer = 0;

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

    // Timers
    if (coyoteTimer > 0) coyoteTimer -= dt;
    if (jumpBufferTimer > 0) jumpBufferTimer -= dt;

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

    // Ground Detection Logic
    bool isOnGround = false;

    // 1. Floor Check
    if (y >= gameRef.size.y) {
      y = gameRef.size.y;
      isOnGround = true;

      if (hasLeftGround) {
        gameRef.gameOver();
      }

      if (velocityY > 0) {
        velocityY = 0;
      }
    }

    // 2. Platform Check
    if (velocityY >= 0) {
      // Only check if falling or flat
      final platforms = gameRef.children.whereType<Platform>();
      for (final platform in platforms) {
        bool currentOverlap = x + width > platform.x &&
            x < platform.x + platform.width &&
            y > platform.y &&
            y - height < platform.y + platform.height;

        // More lenient check thanks to coyote time, but keep collision precise
        // Check if we were previously above the platform
        bool wasAbove = oldY <= platform.y + 5; // Tolerance

        if (currentOverlap && wasAbove) {
          y = platform.y;
          velocityY = 0;
          isOnGround = true;
          platform.onLanded();
          break; // Landed
        }
      }
    }

    // 3. Wall Check (Wall Jump support)
    bool onWall = x <= width / 2 + 10 || x >= gameRef.size.x - width / 2 - 10;
    if (onWall) {
      // Wall slide friction could go here, but for now just treat as "ground" for jump purposes
      isOnGround = true;
    }

    // Coyote Time Reset
    if (isOnGround) {
      coyoteTimer = kCoyoteTime;
    } else if (y < gameRef.size.y - 100) {
      hasLeftGround = true;
    }

    // Jump Execution (Buffer + Coyote)
    if (jumpBufferTimer > 0 && coyoteTimer > 0) {
      performJump();
    }

    // Check Win Condition (Top of level)
    if (y < -50) {
      gameRef.levelCompleted();
    }
  }

  void jump() {
    // Register input immediately into buffer
    jumpBufferTimer = kJumpBufferTime;
  }

  void performJump() {
    velocityY = jumpForce;
    coyoteTimer = 0; // Consume coyote time
    jumpBufferTimer = 0; // Consume buffer
  }
}
