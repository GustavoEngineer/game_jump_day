import 'package:flutter/material.dart';
import '../jump_day_game.dart';

import 'package:google_fonts/google_fonts.dart';

class WinMenu extends StatelessWidget {
  final JumpDayGame game;

  const WinMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 40),
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
