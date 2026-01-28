import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.white12),
            const SizedBox(height: 20),
            Text(
              "MERCHANT",
              style: GoogleFonts.teko(
                fontSize: 60,
                color: const Color(0xFFFF9900),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "NO GOODS AVAILABLE",
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
