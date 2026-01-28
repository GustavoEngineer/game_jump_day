import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/jump_day_game.dart';
import '../game/overlays/win_menu.dart';
import '../game/overlays/game_over_menu.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  bool level2Unlocked = false;
  bool level3Unlocked = false;
  bool level1Completed = false;
  bool level2Completed = false;
  bool level3Completed = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      level2Unlocked = prefs.getBool('level_2_unlocked') ?? false;
      level3Unlocked = prefs.getBool('level_3_unlocked') ?? false;
      level1Completed = prefs.getBool('level_1_completed') ?? false;
      level2Completed = prefs.getBool('level_2_completed') ?? false;
      level3Completed = prefs.getBool('level_3_completed') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222), // Dark Map Background
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          setState(() {
            level2Unlocked = false;
            level3Unlocked = false;
            level1Completed = false;
            level2Completed = false;
            level3Completed = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Progress Reset!")),
          );
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.refresh),
      ),
      body: Stack(
        children: [
          // Background Path
          Positioned.fill(
            child: CustomPaint(
              painter: PathPainter(),
            ),
          ),

          // Header
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "WORLD MAP",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          // Level 3 (Top)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: _buildLevelNode(context,
                level: 3,
                isLocked: !level3Unlocked,
                isCompleted: level3Completed),
          ),

          // Level 2 (Middle)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.2,
            child: _buildLevelNode(context,
                level: 2,
                isLocked: !level2Unlocked,
                isCompleted: level2Completed),
          ),

          // Level 1 (Bottom)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: _buildLevelNode(context,
                level: 1, isLocked: false, isCompleted: level1Completed),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(BuildContext context,
      {required int level, required bool isLocked, required bool isCompleted}) {
    // Colors
    final Color unlockedColor = const Color(0xFFFFD700); // Gold
    final Color lockedColor = const Color(0xFF555555); // Grey
    final Color completedColor = Colors.green;

    final Color nodeColor =
        isLocked ? lockedColor : (isCompleted ? completedColor : unlockedColor);

    final Color textColor = isLocked ? Colors.white38 : Colors.black87;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Level Locked! Complete previous levels first."),
              duration: Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => GameWidget(
                game: JumpDayGame(initialLevel: level),
                overlayBuilderMap: {
                  'WinMenu': (context, JumpDayGame game) => WinMenu(game: game),
                  'GameOverMenu': (context, JumpDayGame game) =>
                      GameOverMenu(game: game),
                },
              ),
            ),
          )
              .then((_) {
            // Refresh progress when returning from game
            _loadProgress();
          });
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                ),
                if (!isLocked)
                  BoxShadow(
                    color: nodeColor.withOpacity(0.6),
                    offset: const Offset(0, 0),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white38, size: 32)
                  : (isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 40)
                      : Text(
                          "$level",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        )),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Painter to draw a connecting line between nodes
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Approximate centers based on Positioned values
    // These need to match the logic in build() relatively closely
    final p1 = Offset(size.width * 0.8 + 40,
        size.height * 0.8 - 40); // Level 1 (Right Bottom)
    final p2 = Offset(
        size.width * 0.2 + 40, size.height * 0.45 + 40); // Level 2 (Left Mid)
    final p3 = Offset(
        size.width * 0.8 + 40, size.height * 0.2 + 40); // Level 3 (Right Top)

    path.moveTo(p1.dx, p1.dy);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.65, p2.dx, p2.dy);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.3, p3.dx, p3.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
