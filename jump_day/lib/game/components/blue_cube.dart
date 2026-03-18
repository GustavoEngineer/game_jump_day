import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'platform.dart';
import '../jump_day_game.dart';
import '../../models/skill_data.dart';
import '../../models/skin_selection_service.dart';
import '../../models/playable_character.dart';

import 'finish_line.dart';
import 'star.dart';

class BlueCube extends PositionComponent
    with HasGameRef<JumpDayGame>, CollisionCallbacks {
  double speed = 250.0; // Reduced speed
  int direction = 1;

  double velocityX = 0; // External horizontal force
  double velocityY = 0; // Vertical velocity
  final double gravity = 2600.0; // Stronger gravity for faster fall
  final double jumpForce = -1050.0; // Tuned jump height
  bool hasLeftGround = false; // Track if player started climbing

  // Star collection tracking
  int starsCollected = 0;

  // Jump Mechanics Optimization
  final double kCoyoteTime = 0.15; // 150ms grace period after leaving ground
  final double kJumpBufferTime = 0.15; // 150ms buffer for early presses
  double coyoteTimer = 0;
  double jumpBufferTimer = 0;

  // ── Sprite support ──────────────────────────────────────────────────────────
  // Se carga dinámicamente; si no existe el archivo, se usa el render() fallback.
  SpriteComponent? _spriteComponent;
  SpriteAnimationComponent? _animationComponent;
  bool _useSprite = false;
  bool _isJumping = false;

  PlayableCharacter? _character;

  BlueCube({PlayableCharacter? character}) : super(size: Vector2.all(50), anchor: Anchor.bottomCenter) {
    _character = character;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = Vector2(gameRef.size.x / 2, gameRef.size.y);
    
    // Tighten hitbox even more. 
    // Moving the hitbox slightly down (position Y) to match the sprite's feet.
    add(RectangleHitbox(
      size: Vector2(size.x * 0.6, size.y * 0.8),
      position: Vector2(size.x * 0.2, size.y * 0.2),
    ));

    if (_character == null) {
      _character = await SkinSelectionService.loadSelectedSkin();
    }
    await _tryLoadSprites();
  }

  /// Intenta cargar los sprites y animaciones del jugador.
  Future<void> _tryLoadSprites() async {
    final rawFolder = _character?.assetFolder ?? 'player/';
    final folder = rawFolder.replaceAll('assets/images/', '');
    final characterName = _character?.name.replaceAll(' ', '_') ?? 'player';

    try {
      // Cargar Animación Idle (4 frames)
      final idleImage = await gameRef.images.load('${folder}${characterName}_Idle_4.png');
      final idleAnimation = SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2.all(32), // Los sprites originales suelen ser 32x32
        ),
      );

      // Cargar Animación Salto (8 frames)
      final jumpImage = await gameRef.images.load('${folder}${characterName}_Jump_8.png');
      final jumpAnimation = SpriteAnimation.fromFrameData(
        jumpImage,
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          loop: false, // El salto no suele loopear
        ),
      );

    // Increase position Y offset even more to fix floating
    // 24.0 pixels should firmly place feet on the ground.
    _animationComponent = SpriteAnimationComponent(
        animation: idleAnimation,
        size: size,
        anchor: Anchor.bottomCenter,
        position: Vector2(0, 24), 
      )..playing = true;

      // Guardar animaciones para swichtar
      _idleAnimation = idleAnimation;
      _jumpAnimation = jumpAnimation;

      add(_animationComponent!);
      _useSprite = true;
    } catch (e) {
      debugPrint('Error loading sprites: $e');
      _useSprite = false;
    }
  }

  SpriteAnimation? _idleAnimation;
  SpriteAnimation? _jumpAnimation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_useSprite) {
      canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFF9900));
    }
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
      _flipSprite();
    } else if (x <= width / 2) {
      direction = 1;
      _flipSprite();
    }

    // Vertical Physics
    velocityY += gravity * dt;
    double dy = velocityY * dt;
    double oldY = y;
    y += dy;

    // Ground Detection Logic
    bool isOnGround = false;

    // 1. Fall Off Screen Check (Immediate Game Over)
    final viewportBottom = gameRef.camera.viewfinder.position.y + gameRef.size.y;
    if (y > viewportBottom + 100) { // Give a tiny bit of leeway
      gameRef.gameOver();
      return; // Stop update
    }

    // 2. Initial Floor (Only for the very first jump)
    if (y >= gameRef.size.y && !hasLeftGround) {
      y = gameRef.size.y;
      isOnGround = true;
      if (velocityY > 0) {
        velocityY = 0;
      }
    }

    // 2. Platform Check
    if (velocityY >= 0) {
      // Only check if falling or flat
      final platforms = gameRef.world.children.whereType<Platform>();
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

    // 3. Wall Check
    bool onWall = x <= width / 2 + 10 || x >= gameRef.size.x - width / 2 - 10;
    if (onWall) {
      isOnGround = true;
    }

    // Coyote Time Reset
    if (isOnGround) {
      coyoteTimer = kCoyoteTime;
      if (_isJumping) {
        _isJumping = false;
        _updateSpriteState();
      }
    } else if (y < gameRef.size.y * 0.8) {
      hasLeftGround = true;
    }

    // Jump Execution (Buffer + Coyote)
    if (jumpBufferTimer > 0 && coyoteTimer > 0) {
      performJump();
    }

    // Win condition now handled via collision with FinishLine
  }

  void jump() {
    // Register input immediately into buffer
    jumpBufferTimer = kJumpBufferTime;
  }

  void performJump() {
    velocityY = jumpForce;
    coyoteTimer = 0; 
    jumpBufferTimer = 0;
    _isJumping = true;
    _updateSpriteState();
  }

  /// Voltea el sprite horizontalmente según la dirección del personaje.
  void _flipSprite() {
    if (_animationComponent != null) {
      _animationComponent!.scale = Vector2(direction.toDouble(), 1);
    }
  }

  /// Cambia el sprite según el estado (salto / suelo).
  void _updateSpriteState() {
    if (_animationComponent == null) return;
    
    if (_isJumping) {
      if (_jumpAnimation != null) {
        _animationComponent!.animation = _jumpAnimation;
        _animationComponent!.animationTicker?.reset();
      }
    } else {
      if (_idleAnimation != null) {
        _animationComponent!.animation = _idleAnimation;
      }
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is FinishLine) {
      // Create victory particles
      _createVictoryEffect();
      other.onPlayerCrossed();
      gameRef.levelCompleted(starsCollected);
    } else if (other is Star) {
      other.collect();
      starsCollected++;
      // Create collection feedback particles
      _createStarCollectionEffect();
    }
  }

  void _createVictoryEffect() {
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 50,
        lifespan: 1.5,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, -100),
          speed: Vector2(
            (Random().nextDouble() - 0.5) * 300,
            (Random().nextDouble() - 0.5) * 300,
          ),
          position: position.clone(),
          child: CircleParticle(
            radius: 2 + Random().nextDouble() * 4,
            paint: Paint()
              ..color = [
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.white,
              ][Random().nextInt(4)]
                  .withOpacity(0.8),
          ),
        ),
      ),
      position: Vector2.zero(),
    );

    gameRef.add(particleComponent);
  }


  void _createStarCollectionEffect() {
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 15,
        lifespan: 0.6,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, -150),
          speed: Vector2(
            (Random().nextDouble() - 0.5) * 150,
            (Random().nextDouble() - 0.5) * 150,
          ),
          position: position.clone(),
          child: CircleParticle(
            radius: 1 + Random().nextDouble() * 2,
            paint: Paint()..color = Colors.yellow.withOpacity(0.8),
          ),
        ),
      ),
      position: Vector2.zero(),
    );

    gameRef.add(particleComponent);
  }
}
