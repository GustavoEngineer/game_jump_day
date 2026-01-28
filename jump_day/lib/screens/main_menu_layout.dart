import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shop_screen.dart';
import 'battle_pass_screen.dart';
import 'login_screen.dart';
import 'level_selection_screen.dart';

class MainMenuLayout extends StatefulWidget {
  const MainMenuLayout({super.key});

  @override
  State<MainMenuLayout> createState() => _MainMenuLayoutState();
}

class _MainMenuLayoutState extends State<MainMenuLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111), // Deep dark matte background
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Industrial Style)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white24, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFFFF9900), // Industrial Orange
                indicatorWeight: 4.0,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: GoogleFonts.teko(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                unselectedLabelStyle: GoogleFonts.teko(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
                tabs: const [
                  Tab(text: "HOME"),
                  Tab(text: "SHOP"),
                  Tab(text: "PASS"),
                  Tab(text: "LOGIN"),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHomeTab(),
                  const ShopScreen(),
                  const BattlePassScreen(),
                  const LoginScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: _buildIndustrialCard(
                title: "SURVIVOR\nRANK",
                icon: Icons.shield_outlined,
                value: "11",
                subtext: "NEXT LEVEL: 5000 XP",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildIndustrialCard(
                title: "CAMPAIGN\nSTATUS",
                icon: Icons.map_outlined,
                isAction: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const LevelSelectionScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustrialCard({
    required String title,
    required IconData icon,
    String? value,
    String? subtext,
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isAction ? const Color(0xFFFF9900) : Colors.white12,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4), // Sharp-ish corners
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.teko(
                fontSize: 32,
                height: 0.9,
                fontWeight: FontWeight.bold,
                color: isAction ? const Color(0xFFFF9900) : Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 2,
              width: 50,
              color: isAction ? const Color(0xFFFF9900) : Colors.white24,
            ),
            const Spacer(),
            Center(
              child: Icon(
                icon,
                size: 80,
                color: isAction ? const Color(0xFFFF9900) : Colors.white24,
              ),
            ),
            const Spacer(),
            if (value != null)
              Text(
                value,
                style: GoogleFonts.teko(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (isAction)
              Center(
                child: Text(
                  "OPEN MAP >",
                  style: GoogleFonts.teko(
                    fontSize: 28,
                    color: const Color(0xFFFF9900),
                  ),
                ),
              ),
            if (subtext != null)
              Text(
                subtext,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
