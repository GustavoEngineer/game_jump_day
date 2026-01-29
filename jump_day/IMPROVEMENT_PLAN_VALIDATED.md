# Validación e Instrucciones de Implementación — Jump Day 2.0

Este documento valida el plan de mejoras propuesto y mapea las acciones concretas al código existente en el repositorio.

**Resumen:**

- **Estado:** Plan técnicamente viable con Flame.
- **Cambios principales:** cámara vertical con seguimiento, generación por altura, coleccionables (`Star`), meta física (`FinishLine`), y detección de colisiones basada en `CollisionCallbacks`.

**Requisitos de Flame confirmados:**

- `CameraComponent` / `camera.viewfinder.anchor` / `camera.follow()` — soporte confirmado.
- `HasCollisionDetection`, `CollisionCallbacks`, y `ShapeHitbox` (`CircleHitbox`) — soporte confirmado.
- `World` y adición dinámica de componentes desde la lógica de generación — soporte confirmado.

**Mapa de implementaciones y archivos**

- **Juego principal:** `JumpDayGame` — [lib/game/jump_day_game.dart](lib/game/jump_day_game.dart#L1-L135)
  - Añadir mixin: `with HasCollisionDetection`.
  - Configurar cámara en `onLoad()`:

```dart
// ejemplo
camera.viewfinder.anchor = Anchor.bottomCenter;
// Después de crear/añadir el jugador:
camera.follow(cube!);
// Opcional: camera.setBounds(...) para limitar la cámara
```

- Reescribir `_startLevel()` para usar `targetHeight` (p. ej. 3000..5000) y generar plataformas hasta alcanzar la altura objetivo. Usar coordenadas Y negativas para crecer hacia arriba.
- Integrar generación de `Star` con probabilidad (ej. 20%) y límite por nivel (máx 3).
- Añadir el `FinishLine` en `-targetHeight`.
- Actualizar `levelCompleted()` para aceptar `int stars` y guardar en `SharedPreferences` (`level_X_stars`).

- **Jugador:** `BlueCube` — [lib/game/components/blue_cube.dart](lib/game/components/blue_cube.dart#L1-L141)
  - Añadir `CollisionCallbacks` al `class`:

```dart
class BlueCube extends PositionComponent
    with HasGameRef<JumpDayGame>, CollisionCallbacks {
  // ...
}
```

- Añadir un `RectangleHitbox` (o `CircleHitbox` si prefieres) en `onLoad()` para que el jugador colisione.
- Eliminar la condición de victoria por coordenada `if (y < -50)` y en su lugar manejar colisión con `FinishLine`:

```dart
@override
void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  super.onCollisionStart(intersectionPoints, other);
  if (other is FinishLine) {
    gameRef.levelCompleted(starsCollected);
  } else if (other is Star) {
    // recolectar star
    other.removeFromParent();
    starsCollected++;
  }
}
```

- **Plataformas:** `Platform` — [lib/game/components/platform.dart](lib/game/components/platform.dart#L1-L122)
  - Mantener comportamiento actual; la generación se ajusta desde `_startLevel()` en `JumpDayGame`.
  - Durante la generación, posicionar `Star` sobre algunas plataformas según probabilidad.

- **Nuevos componentes a crear:**
  - `lib/game/components/star.dart`
    - `Star` extiende `PositionComponent` con `CollisionCallbacks` y añade `CircleHitbox()`.
    - `collisionType` puede ser `CollisionType.passive` para no empujar.
  - `lib/game/components/finish_line.dart`
    - `FinishLine` extiende `PositionComponent` con `CollisionCallbacks` y añade `RectangleHitbox(collisionType: CollisionType.passive)` que ocupa `gameRef.size.x` de ancho.

**Plan de ejecución (resumido en pasos técnicos):**

- **Paso 1:** Modificar `JumpDayGame`:
  - Añadir `HasCollisionDetection` al `class`.
  - Configurar `camera.viewfinder.anchor = Anchor.bottomCenter` en `onLoad()`.
  - Preparar `targetHeight` y lógica de generación por altura.

- **Paso 2:** Crear `Star` y `FinishLine` en `lib/game/components/`.

- **Paso 3:** Actualizar `BlueCube`:
  - Añadir `CollisionCallbacks` y un `Hitbox` en `onLoad()`.
  - Remover verificación `if (y < -50)`.
  - Implementar `onCollisionStart` para estrellas y meta.

- **Paso 4:** Actualizar `_startLevel()` para generar plataformas hasta `targetHeight`, colocar estrellas y posicionar la `FinishLine`.

- **Paso 5:** Persistencia y UI:
  - Cambiar `levelCompleted()` para recibir `stars` y guardarlos con `SharedPreferences` (`level_X_stars`).
  - Mostrar overlay de victoria con la cantidad de estrellas obtenidas.

**Consideraciones y notas rápidas:**

- Mantener el culling: usar `camera.canSee(component)` si la generación dinámica produce muchos objetos para optimizar rendimiento.
- Para aislar la detección de colisiones sólo a la escena, se puede usar `World with HasCollisionDetection` si se prefiere.
- Testear en niveles con `targetHeight` pequeño primero (ej. 800) y luego escalar a 3000+.

---

¿Deseas que inserte este contenido dentro del archivo original `IMPROVEMENT_PLAN.md` o lo dejamos como `IMPROVEMENT_PLAN_VALIDATED.md` en la raíz del proyecto?
