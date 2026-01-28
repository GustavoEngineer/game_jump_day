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
        description: 'Permite aferrarse a las superficies verticales.',
        levelRequired: 3,
        cost: 500,
        icon: Icons.back_hand,
        state: SkillState.available,
        parentIds: ['jump'],
        x: 0.6,
        y: 0.15,
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
        x: 0.6,
        y: 0.5,
      ),

      // Branch 3 - Bounce
      Skill(
        id: 'bounce',
        name: 'Rebotar al caer',
        description: 'Si caes al suelo, rebotas automáticamente.',
        levelRequired: 5,
        cost: 1000,
        icon: Icons.sports_basketball,
        state: SkillState.locked,
        parentIds: ['jump'],
        x: 0.6,
        y: 0.85,
      ),
    ];
  }
}
