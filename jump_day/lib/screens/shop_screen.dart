import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/skill_data.dart';
import 'widgets/skill_node.dart';
import 'widgets/skill_tree_painter.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late List<Skill> skills;
  Skill? selectedSkill;
  Skill? selectedSkill; // Track selected skill

  @override
  void initState() {
    super.initState();
    skills = SkillRepo.getSkills();
    selectedSkill = skills.first; // Default selection
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Column(
        children: [
          // 1. TOP HEADER: "SKILLS"
          Container(
            height: 80, // Thinner header
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12, width: 1),
              ),
              color: Color(0xFF1A1A1A),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            alignment: Alignment.centerLeft,
            child: Text(
              "SKILLS",
              style: GoogleFonts.teko(
                fontSize: 48,
                height: 0.9,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9900),
              ),
            ),
          ),

          // BOTTOM: Tree
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background grid
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),

                    // Lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SkillTreePainter(skills),
                      ),
                    ),

                    // Nodes
                    ...skills.map((skill) {
                      // Calculate position based on container size
                      // Using a safe area margin to avoid edges
                      final double margin = 50;
                      final double w = constraints.maxWidth - (margin * 2);
                      final double h = constraints.maxHeight - (margin * 2);

                      final left =
                          margin + (skill.x * w) - 40; // -40 for half node size
                      final top = margin + (skill.y * h) - 40;

                      return Positioned(
                        left: left,
                        top: top,
                        child: SkillNodeWidget(
                          skill: skill,
                          isSelected: selectedSkill?.id == skill.id,
                          onTap: () {
                            setState(() {
                              selectedSkill = skill;
                            });
                          },
                        ),
                      );
                    }).toList(),

                    // INFO OVERLAY (Visible when a skill is selected)
                    if (selectedSkill != null)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E).withOpacity(0.95),
                            border: const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFFF9900), width: 2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(selectedSkill!.icon,
                                  color: Colors.white, size: 32),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedSkill!.name,
                                    style: GoogleFonts.teko(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.0),
                                  ),
                                  Text(
                                    selectedSkill!.state.name.toUpperCase(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 10,
                                      color: const Color(0xFFFF9900),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                child: Text(
                                  selectedSkill!.description,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double step = 50;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
