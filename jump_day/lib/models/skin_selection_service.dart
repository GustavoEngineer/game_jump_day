import 'package:shared_preferences/shared_preferences.dart';
import '../models/playable_character.dart';

class SkinSelectionService {
  static const _selectedSkinKey = 'selected_skin';

  static Future<void> saveSelectedSkin(String skinName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSkinKey, skinName);
  }

  static Future<PlayableCharacter> loadSelectedSkin() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_selectedSkinKey);
    return playableCharacters.firstWhere(
      (c) => c.name == name,
      orElse: () => playableCharacters[0],
    );
  }
}
