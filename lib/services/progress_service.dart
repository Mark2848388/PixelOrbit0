import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class ProgressService extends ChangeNotifier {
  late SharedPreferences _prefs;
  late Player player;
  bool tutorialCompleted = false;
  bool isReady = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString('player');
    if (raw != null) {
      player = Player.fromJson(jsonDecode(raw));
    } else {
      player = Player();
    }
    tutorialCompleted = _prefs.getBool('tutorial_completed') ?? false;
    isReady = true;
    notifyListeners();
  }

  Future<void> save() async {
    await _prefs.setString('player', jsonEncode(player.toJson()));
    await _prefs.setBool('tutorial_completed', tutorialCompleted);
  }

  void completeTutorial() {
    tutorialCompleted = true;
    save();
    notifyListeners();
  }

  void updatePlayer(void Function(Player p) updater) {
    updater(player);
    save();
    notifyListeners();
  }

  void addCoins(int amount) {
    player.coins += amount;
    save();
    notifyListeners();
  }

  void addCrystals(int amount) {
    player.crystals += amount;
    save();
    notifyListeners();
  }

  void spendCoins(int amount) {
    if (player.coins >= amount) {
      player.coins -= amount;
      save();
      notifyListeners();
    }
  }

  void spendCrystals(int amount) {
    if (player.crystals >= amount) {
      player.crystals -= amount;
      save();
      notifyListeners();
    }
  }

  void unlockCharacter(String id) {
    if (!player.unlockedCharacters.contains(id)) {
      player.unlockedCharacters.add(id);
      // Гибрид: даём 2 штуки особого юнита при разблокировке
      player.specialUnitCounts[id] = (player.specialUnitCounts[id] ?? 0) + 2;
      save();
      notifyListeners();
    }
  }

  void setActiveHero(String id) {
    if (player.isCharacterUnlocked(id) || id == 'default') {
      player.activeHeroId = id;
      save();
      notifyListeners();
    }
  }

  void addSpecialUnit(String id, int count) {
    player.specialUnitCounts[id] = (player.specialUnitCounts[id] ?? 0) + count;
    save();
    notifyListeners();
  }

  void unlockCampaignLevel(int level) {
    if (level > player.campaignLevelUnlocked) {
      player.campaignLevelUnlocked = level;
      save();
      notifyListeners();
    }
  }
}