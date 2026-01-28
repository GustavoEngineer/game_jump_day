import 'package:flutter/material.dart';
import '../../models/skill_data.dart';

class SkillTreePainter extends CustomPainter {
  final List<Skill> skills;

  SkillTreePainter(this.skills);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;

    // Create a map for quick lookup
    final Map<String, Skill> skillMap = {for (var s in skills) s.id: s};

    for (var skill in skills) {
      for (var parentId in skill.parentIds) {
        final parent = skillMap[parentId];
        if (parent != null) {
          // Determine line color
          // Orange if both are unlocked/mastered, grey otherwise.
          final bool activeConnection = (parent.state != SkillState.locked) &&
              (skill.state != SkillState.locked);

          paint.color =
              activeConnection ? const Color(0xFFFF9900) : Colors.white12;

          // Draw line
          final p1 = Offset(parent.x * size.width, parent.y * size.height);
          final p2 = Offset(skill.x * size.width, skill.y * size.height);

          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simple repaint for now
  }
}
