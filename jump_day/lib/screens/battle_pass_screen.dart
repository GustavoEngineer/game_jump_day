import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BattlePassScreen extends StatelessWidget {
  const BattlePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.military_tech_outlined,
                size: 100, color: Colors.white12),
            const SizedBox(height: 20),
            Text(
              "BATTLE PASS",
              style: GoogleFonts.teko(
                fontSize: 60,
                color: const Color(0xFFFF9900),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "SEASON 1: SURVIVAL",
              style: GoogleFonts.roboto(
                fontSize: 18,
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
