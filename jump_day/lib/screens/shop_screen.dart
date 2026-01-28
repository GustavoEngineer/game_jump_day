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
  Skill? selectedSkill; // Track selected skill
  bool showSkills = true; // Tab state

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
          // 1. TOP HEADER: TABS
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showSkills = true;
                    });
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.teko(
                      fontSize: showSkills ? 48 : 32,
                      height: 0.9,
                      fontWeight: FontWeight.bold,
                      color:
                          showSkills ? const Color(0xFFFF9900) : Colors.white24,
                    ),
                    child: const Text("SKILLS"),
                  ),
                ),
                const SizedBox(width: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showSkills = false;
                      });
                    },
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.teko(
                        fontSize: !showSkills ? 48 : 32,
                        height: 0.9,
                        fontWeight: FontWeight.bold,
                        color: !showSkills
                            ? const Color(0xFFFF9900)
                            : Colors.white24,
                      ),
                      child: const Text("COINS"),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM: Content
          Expanded(
            child: showSkills ? _buildSkillTree() : _buildCoinsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsList() {
    final List<Map<String, dynamic>> coinOffers = [
      {'coins': 10, 'price': 30},
      {'coins': 30, 'price': 100},
      {'coins': 50, 'price': 120},
      {'coins': 100, 'price': 200},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(32),
      itemCount: coinOffers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final offer = coinOffers[index];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFFFF9900), width: 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9900).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Color(0xFFFF9900),
                  size: 32,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${offer['coins']} COINS",
                    style: GoogleFonts.teko(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "Paquete de monedas",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "\$${offer['price']}",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillTree() {
    return LayoutBuilder(
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
            Positioned(
              top: 160, // Leave space for info overlay
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                painter: SkillTreePainter(skills),
              ),
            ),

            // Nodes
            ...skills.map((skill) {
              // Calculate position based on container size
              // Using a safe area margin to avoid edges
              final double margin = 50;
              final double treeTopOffset = 160; // Must match line painter

              final double w = constraints.maxWidth - (margin * 2);
              final double availableHeight =
                  constraints.maxHeight - treeTopOffset;
              final double h = availableHeight - (margin * 2);

              final left =
                  margin + (skill.x * w) - 40; // -40 for half node size

              // Calculate top relative to the whole stack
              // treeTopOffset (start of tree area) + margin (inside tree area) + y*h
              final top = treeTopOffset + margin + (skill.y * h) - 40;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.95),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFFF9900), width: 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(selectedSkill!.icon,
                              color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedSkill!.description,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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
