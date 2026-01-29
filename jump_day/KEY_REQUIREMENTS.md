# Requisitos Clave - Jump Day

Este documento define los requerimientos funcionales y técnicos necesarios para alcanzar la versión mejorada ("2.0") del juego.

## 1. Requisitos Funcionales (Gameplay)

### 1.1 Sistema de Niveles y Navegación
*   **Niveles Extendidos:** El juego debe soportar mapas verticales de gran altura (ej. >3000px) sin cortes de carga.
*   **Cámara de Seguimiento:** La cámara debe seguir al jugador (`BlueCube`) suavemente en el eje Y, manteniendo siempre visible el camino inmediato superior e inferior.
*   **Meta Física:** Debe existir un objeto visual claro (`FinishLine`) que marque el fin del nivel, reemplazando la lógica invisible actual.

### 1.2 Sistema de Progresión
*   **Coleccionables (Estrellas):**
    *   3 Estrellas distribuidas estratégicamente por nivel.
    *   Deben ser opcionales para terminar el nivel, pero obligatorias para el "100%".
*   **Persistencia de Datos:** El juego debe guardar localmente:
    *   Niveles desbloqueados.
    *   Mejor puntuación de estrellas por nivel.

### 1.3 Mecánicas de Juego
*   **Controles:** Input de un solo toque ("Tap to Jump").
*   **Físicas:**
    *   Gravedad constante.
    *   Rebote automático en paredes.
    *   "Coyote Time" para saltos más justos en bordes de plataformas.
*   **Obstáculos:**
    *   Plataformas Estáticas.
    *   Plataformas Móviles (Horizontal).
    *   Plataformas Rompibles (Timer de explosión).
    *   Proyectiles/Enemigos básicos.

## 2. Requisitos Técnicos

### 2.1 Motor y Rendimiento
*   **Framework:** Flutter + Flame Engine (v1.13.0+).
*   **Target FPS:** 60 FPS estables.
*   **Gestión de Memoria:** Los objetos que salen de pantalla (muy abajo) deben ser eliminados o reciclados para evitar fugas de memoria en niveles largos.

### 2.2 UI/UX
*   **HUD (Heads-Up Display):** Debe mostrar las estrellas recolectadas en tiempo real durante la partida.
*   **Menús:**
    *   Pantalla de "Nivel Completado" (Resumen de estrellas).
    *   Pantalla de "Game Over" (Reinicio rápido).
*   **Diseño:** Estilo industrial/minimalista con colores de alto contraste para visibilidad clara de elementos interactivos vs. fondo.

### 2.3 Compatibilidad
*   Soporte para múltiples resoluciones de pantalla (desde teléfonos compactos hasta tabletas).
*   El área de juego debe adaptarse (`Safe Area`) para no quedar oculta por 'notches' o barras de navegación.
