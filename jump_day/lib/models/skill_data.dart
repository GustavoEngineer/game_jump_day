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
      // Root Skills
      Skill(
        id: 's1',
        name: 'Windmill',
        description:
            'Strike multiple enemies with a devastating 360-degree attack.',
        levelRequired: 8,
        cost: 1000,
        icon: Icons.wind_power,
        state: SkillState.mastered,
        x: 0.1,
        y: 0.5,
      ),

      // Branch 1 - Upper
      Skill(
        id: 'u1',
        name: 'Vitality',
        description: 'Increases max health by 20%.',
        levelRequired: 10,
        cost: 1500,
        icon: Icons.favorite,
        state: SkillState.available,
        parentIds: ['s1'],
        x: 0.6,
        y: 0.15, // Spread out vertically
      ),

      // Branch 2 - Middle
      Skill(
        id: 'm1',
        name: 'Power Strike',
        description: 'Deal 50% more damage with heavy attacks.',
        levelRequired: 10,
        cost: 1500,
        icon: Icons.flash_on,
        state: SkillState.available,
        parentIds: ['s1'],
        x: 0.6,
        y: 0.5,
      ),

      // Branch 3 - Lower
      Skill(
        id: 'l1',
        name: 'Agility',
        description: 'Movement speed increased by 15%.',
        levelRequired: 10,
        cost: 1500,
        icon: Icons.directions_run,
        state: SkillState.available,
        parentIds: ['s1'],
        x: 0.6,
        y: 0.85,
      ),
    ];
  }
}
