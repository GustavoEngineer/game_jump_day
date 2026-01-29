# Plan de Mejoras: Jump Day 2.0

Este documento detalla la lógica técnica y el plan de implementación para las mejoras de jugabilidad en *Jump Day*, enfocándose en la extensión de niveles y el sistema de progresión.

## 1. Niveles Ampliados y Sistema de Cámara ("Scrolling")

Actualmente, el juego opera en una sola vista estática. Para soportar niveles más largos y dinámicos, implementaremos un sistema de cámara de seguimiento.

### Definición Técnica
*   **Coordenadas:** El mundo crecerá verticalmente hacia coordenadas negativas (Y < 0).
*   **CameraComponent:** Se utilizará el componente de cámara nativo de Flame.
    *   **Behavior:** `FollowBehavior` anclado al `BlueCube`.
    *   **Restricciones:** La cámara debe seguir al jugador *solo* en el eje vertical (Y), manteniendo el eje X fijo para preservar el encuadre del nivel.
    *   **Viewfinder:** Configurado con `anchor: Anchor.bottomCenter` para mantener al jugador en la zona inferior de la pantalla, maximizando la visibilidad del camino hacia arriba.

### Lógica de Generación
*   Se sustituirá el bucle fijo de plataformas (ej. `i < 15`) por una generación basada en altura.
*   **Variable `targetHeight`:** Definirá la altura total del nivel (ej. 3000 a 5000 píxeles).
*   El generador colocará plataformas incrementalmente hasta alcanzar esta altura objetivo.

---

## 2. Sistema de Estrellas (Coleccionables)

Para medir el dominio del nivel ("100% completado"), introduciremos objetos coleccionables.

### Componente: `Star`
*   **Tipo:** `PositionComponent` con `Asset` visual (dibujado por Canvas o Sprite).
*   **Físicas:** Sensor (`CollisionCallbacks`), no afecta el movimiento del jugador.
*   **Hitbox:** `CircleHitbox` para detección radial precisa.

### Integración
*   **Probabilidad de Spawn:** Durante la generación de plataformas, habrá un % de probabilidad (ej. 20%) de generar una `Star` sobre la plataforma actual.
*   **Límite:** Se controlará la generación para asegurar un máximo de 3 estrellas por nivel.
*   **Persistencia:** Al finalizar el nivel, se guardará el número de estrellas obtenidas en `SharedPreferences` (ej. `level_1_stars: 2`).

---

## 3. Línea de Meta Física (`FinishLine`)

Reemplazo de la condición de victoria invisible basada en coordenadas por un elemento tangible.

### Componente: `FinishLine`
*   **Visual:** Una línea, bandera o portal renderizado al final del nivel.
*   **Ubicación:** Coordenada Y final (`-targetHeight`).
*   **Ancho:** Ocupa todo el ancho de la pantalla (`gameRef.size.x`) para asegurar que el jugador la toque.

### Nueva Condición de Victoria
*   Eliminar chequeo en `update()`.
*   Implementar `onCollisionStart` en el jugador o la meta.
*   Al colisionar:
    1.  Pausar el juego.
    2.  Calcular estrellas recolectadas.
    3.  Llamar a `levelCompleted(stars)`.
    4.  Mostrar menú de victoria con la puntuación.

---

## Plan de Ejecución

1.  **Cámara y Mundo:** Refactorizar `JumpDayGame` para inicializar y configurar el sistema de cámara `World`.
2.  **Componentes Visuales:** Crear las clases `Star.dart` y `FinishLine.dart` con sus respectivos `render()` y hitboxes.
3.  **Lógica del Jugador:** Añadir `HasCollisionDetection` al juego y `CollisionCallbacks` a `BlueCube` para manejar la recolección y la victoria.
4.  **Generador de Niveles:** Reescribir `_startLevel` para usar la nueva lógica de altura y posicionar los nuevos elementos.
5.  **UI y Persistencia:** Actualizar la pantalla de victoria y el guardado de datos.
