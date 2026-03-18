import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/playable_character.dart';
import '../models/skin_selection_service.dart';

class SkinsScreen extends StatefulWidget {
  final PlayableCharacter? initialSelectedCharacter;
  final VoidCallback? onSkinChanged;

  const SkinsScreen({
    Key? key,
    this.initialSelectedCharacter,
    this.onSkinChanged,
  }) : super(key: key);

  @override
  State<SkinsScreen> createState() => _SkinsScreenState();
}

class _SkinsScreenState extends State<SkinsScreen> {
  PlayableCharacter? selectedCharacter;

  @override
  void initState() {
    super.initState();
    selectedCharacter = widget.initialSelectedCharacter;
    _loadSelectedSkin();
  }

  Future<void> _loadSelectedSkin() async {
    final skin = await SkinSelectionService.loadSelectedSkin();
    setState(() {
      selectedCharacter = skin;
    });
  }

  Future<void> _onSelect(PlayableCharacter character) async {
    await SkinSelectionService.saveSelectedSkin(character.name);
    setState(() {
      selectedCharacter = character;
    });
    widget.onSkinChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: Text(
          'ARMORY: CHARACTER SKINS',
          style: GoogleFonts.teko(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "SELECT YOUR OPERATOR",
              style: GoogleFonts.roboto(
                color: Colors.white54,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Single large card per row for premium look
                childAspectRatio: 1.8,
                mainAxisSpacing: 20,
              ),
              itemCount: playableCharacters.length,
              itemBuilder: (context, index) {
                final character = playableCharacters[index];
                final isSelected = character.name == selectedCharacter?.name;
                return _buildCharacterCard(character, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(PlayableCharacter character, bool isSelected) {
    const orangeAccent = Color(0xFFFF9900);
    
    return GestureDetector(
      onTap: () => _onSelect(character),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isSelected ? orangeAccent : Colors.white12,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: orangeAccent.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: Stack(
          children: [
            // Background Pattern/Grid
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: GridPainter()),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Character Sprite Preview
                  Expanded(
                    flex: 2,
                    child: Hero(
                      tag: 'skin_${character.name}',
                      child: Image.asset(
                        character.previewAsset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none, // Pixel art sharp
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Character Info
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name.toUpperCase(),
                          style: GoogleFonts.teko(
                            fontSize: 36,
                            color: isSelected ? orangeAccent : Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          width: 40,
                          color: isSelected ? orangeAccent : Colors.white24,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "HEAVY INFANTRY UNIT", // Or dynamic if available
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.white54,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.verified, color: orangeAccent, size: 32),
                ],
              ),
            ),
            
            // Corner details for industrial look
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: isSelected ? orangeAccent : Colors.white24, width: 2),
                    left: BorderSide(color: isSelected ? orangeAccent : Colors.white24, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
