import 'package:flutter/material.dart';
import '../jump_day_game.dart';
import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';

class WinMenu extends StatelessWidget {
  final JumpDayGame game;

  const WinMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Get the stars collected from the player
    final starsCollected = game.cube?.starsCollected ?? 0;

    return Center(
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFFFF9900), width: 4),
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "MISSION COMPLETE",
              style: GoogleFonts.teko(
                color: const Color(0xFFFF9900),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 0.9,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "OBJECTIVE SECURED",
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 30),

            // Stars Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isCollected = index < starsCollected;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomPaint(
                    size: const Size(50, 50),
                    painter: StarPainter(
                      isCollected: isCollected,
                      color: isCollected
                          ? const Color(0xFFFFD700)
                          : Colors.grey.shade700,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              "$starsCollected / 3 STARS",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                "RETURN TO BASE",
                style: GoogleFonts.teko(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for drawing pixel art stars
class StarPainter extends CustomPainter {
  final bool isCollected;
  final Color color;

  StarPainter({required this.isCollected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isCollected ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2;

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final innerRadius = radius * 0.4;

    // Create 5-pointed star path
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final r = i % 2 == 0 ? radius : innerRadius;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw star
    if (isCollected) {
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) =>
      oldDelegate.isCollected != isCollected || oldDelegate.color != color;
}
