import 'package:flutter/material.dart';

enum SkillState { locked, available, mastered }

class Skill {
  final String id;
  final String name;
  final String description;
  final int levelRequired;
  final int cost;
  final IconData icon;
  SkillState state;
  final List<String> parentIds;

  // Layout position (0-1 range for relative positioning)
  final double x;
  final double y;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.levelRequired,
    required this.cost,
    required this.icon,
    this.state = SkillState.locked,
    this.parentIds = const [],
    required this.x,
    required this.y,
  });
}

class SkillRepo {
  static List<Skill> getSkills() {
    return [
      // Root Skill
      Skill(
        id: 'jump',
        name: 'Saltar',
        description: 'La base de todo movimiento. Permite elevarse del suelo.',
        levelRequired: 1,
        cost: 0,
        icon: Icons.arrow_upward,
        state: SkillState.mastered,
        x: 0.1,
        y: 0.5,
      ),

      // Branch 1 - Wall Stick
      Skill(
        id: 'wall_stick',
        name: 'Pegarse en las paredes',
        description: 'Permite aferrarse a las superficies verticales y saltar desde ellas.',
        levelRequired: 3,
        cost: 500,
        icon: Icons.back_hand,
        state: SkillState.available,
        parentIds: ['jump'],
        x: 0.4,
        y: 0.2,
      ),

      // Branch 2 - Double Jump
      Skill(
        id: 'double_jump',
        name: 'Saltar en el aire',
        description: 'Realiza un segundo salto mientras estás en el aire.',
        levelRequired: 5,
        cost: 1000,
        icon: Icons.keyboard_double_arrow_up,
        state: SkillState.locked,
        parentIds: ['jump'],
        x: 0.4,
        y: 0.5,
      ),

      // Branch 3 - Power Jump
      Skill(
        id: 'power_jump',
        name: 'Salto Potenciado',
        description: 'Aumenta la fuerza de tus saltos un 20%.',
        levelRequired: 2,
        cost: 300,
        icon: Icons.expand_less,
        state: SkillState.available,
        parentIds: ['jump'],
        x: 0.4,
        y: 0.8,
      ),

      // Advanced - Magnet
      Skill(
        id: 'magnet',
        name: 'Imán de Estrellas',
        description: 'Atrae las estrellas cercanas automáticamente.',
        levelRequired: 6,
        cost: 1500,
        icon: Icons.adjust,
        state: SkillState.locked,
        parentIds: ['double_jump'],
        x: 0.7,
        y: 0.5,
      ),

      // Advanced - Glide
      Skill(
        id: 'glide',
        name: 'Planeo Suave',
        description: 'Mantén presionado para descender lentamente.',
        levelRequired: 10,
        cost: 3000,
        icon: Icons.air,
        state: SkillState.locked,
        parentIds: ['wall_stick'],
        x: 0.7,
        y: 0.2,
      ),

      // Advanced - Shield
      Skill(
        id: 'shield',
        name: 'Escudo de Energía',
        description: 'Te protege de una caída al vacío por partida.',
        levelRequired: 8,
        cost: 5000,
        icon: Icons.security,
        state: SkillState.locked,
        parentIds: ['power_jump'],
        x: 0.7,
        y: 0.8,
      ),

      // Ultimate - Time Warp
      Skill(
        id: 'time_warp',
        name: 'Fisura Temporal',
        description: 'Ralentiza el tiempo por 3 segundos.',
        levelRequired: 15,
        cost: 10000,
        icon: Icons.hourglass_empty,
        state: SkillState.locked,
        parentIds: ['magnet', 'glide', 'shield'],
        x: 0.95,
        y: 0.5,
      ),
    ];
  }
}
