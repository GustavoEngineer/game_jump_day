import 'package:flutter/material.dart';
import '../../models/skill_data.dart';

class SkillTreePainter extends CustomPainter {
  final List<Skill> skills;
  final double topOffset;

  SkillTreePainter(this.skills, {this.topOffset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // We need to map skills by ID for easy parent lookup
    final Map<String, Skill> skillMap = {for (var s in skills) s.id: s};

    // Paint configuration
    final Paint linePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint activeLinePaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // We assume the same margin/padding logic as the widget layout
    // This duplicates some logic but fine for now
    final double margin = 50;
    final double w = size.width - (margin * 2);
    final double h = size.height - (margin * 2);

    for (var skill in skills) {
      if (skill.parentIds.isEmpty) continue;

      // Current node position
      final Offset end = Offset(
        margin + (skill.x * w),
        margin + (skill.y * h) + topOffset, // Apply offset
      );

      for (var parentId in skill.parentIds) {
        final parent = skillMap[parentId];
        if (parent != null) {
          final Offset start = Offset(
            margin + (parent.x * w),
            margin + (parent.y * h) + topOffset, // Apply offset
          );

          // Draw line
          // If both are unlocked/mastered, draw active line?
          // For now just simple logic: if parent is mastered, line is active?
          // Or just simple white lines
          bool isActive = parent.state == SkillState.mastered ||
              (parent.state == SkillState.available &&
                  skill.state != SkillState.locked);

          canvas.drawLine(start, end, isActive ? activeLinePaint : linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simple repaint for now
  }
}
