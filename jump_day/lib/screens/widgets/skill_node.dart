import 'package:flutter/material.dart';

import '../../models/skill_data.dart';

class SkillNodeWidget extends StatelessWidget {
  final Skill skill;
  final bool isSelected;
  final VoidCallback? onTap;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;

  const SkillNodeWidget({
    super.key,
    required this.skill,
    required this.isSelected,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on state
    final Color borderColor = isSelected
        ? const Color(0xFFFF9900) // Orange when selected
        : (skill.state == SkillState.locked
            ? Colors.white12
            : (skill.state == SkillState.mastered
                ? Colors.amber
                : Colors.white54));

    final Color iconColor = skill.state == SkillState.locked
        ? Colors.white12
        : (skill.state == SkillState.mastered ? Colors.amber : Colors.white);

    final Color glowColor = isSelected
        ? const Color(0xFFFF9900).withOpacity(0.5)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 2),
          // Hexagon shape simulation with basic box for now as requested "simple"
          // but let's add some box shadow for "glow"
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
          shape: BoxShape.rectangle, // Simple box
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              skill.state == SkillState.locked ? Icons.lock : skill.icon,
              size: 40,
              color: iconColor,
            ),
            if (skill.state == SkillState.mastered)
              Positioned(
                bottom: 5,
                right: 5,
                child: Icon(Icons.check_circle, size: 16, color: Colors.amber),
              )
          ],
        ),
      ),
    );
  }
}
