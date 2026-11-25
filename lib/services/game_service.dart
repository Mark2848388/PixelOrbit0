import 'dart:math' as math;
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enemy.dart';
import '../models/unit.dart';
import '../models/campaign.dart';
import '../models/season.dart';
import 'progress_service.dart';

enum GameMode { endless, campaign }

class GameService extends ChangeNotifier {
  final ProgressService progress;
  final Random _rng = Random();

  // Game state
  bool isPlaying = false;
  bool isPaused = false;
  GameMode mode = GameMode.endless;
  CampaignLevel? currentCampaignLevel;

  // Arena
  final Offset center = const Offset(180, 280);
  final double arenaRadius = 140;

  // Entities
  List<Enemy> enemies = [];
  List<PlacedUnit> units = [];
  UnitType? selectedUnitType;

  // Special unit selection (hybrid)
  String? selectedSpecialId;

  // Stats
  int wave = 0;
  int kills = 0;
  int coinsEarned = 0;
  double heroHp = 100;
  double heroMaxHp = 100;
  double heroShield = 0; // temporary shield from Nova Guardian
  int energy = 50;

  // Hero passive timers
  double _shieldTimer = 0;

  Timer? _gameTimer;
  double _spawnTimer = 0;
  double _waveTimer = 0;
  int _enemiesThisWave = 0;
  int _enemiesSpawned = 0;

  GameService(this.progress) {
    heroHp = progress.player.currentHp;
    heroMaxHp = progress.player.maxHp;
    energy = progress.player.energy;
  }

  SpecialCharacter? get activeHero {
    final id = progress.player.activeHeroId;
    if (id == 'default') return null;
    return getSpecialCharacter(id);
  }

  void startEndless() {
    mode = GameMode.endless;
    _reset();
    isPlaying = true;
    _startLoop();
    notifyListeners();
  }

  void startCampaign(CampaignLevel level) {
    mode = GameMode.campaign;
    currentCampaignLevel = level;
    _reset();
    isPlaying = true;
    _startLoop();
    notifyListeners();
  }

  void _reset() {
    enemies.clear();
    units.clear();
    selectedUnitType = null;
    selectedSpecialId = null;
    wave = 0;
    kills = 0;
    coinsEarned = 0;
    heroHp = progress.player.maxHp;
    heroMaxHp = progress.player.maxHp;
    heroShield = 0;
    energy = progress.player.energy;
    _spawnTimer = 0;
    _waveTimer = 0;
    _enemiesThisWave = 0;
    _enemiesSpawned = 0;
    _shieldTimer = 0;
    _nextWave();
  }

  void _startLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!isPlaying || isPaused) return;
      _tick(0.05);
    });
  }

  void _tick(double dt) {
    final hero = activeHero;

    // Periodic shield (Nova Guardian)
    if (hero != null && hero.heroPeriodicShield) {
      _shieldTimer += dt;
      if (_shieldTimer >= hero.heroShieldInterval) {
        _shieldTimer = 0;
        heroShield = hero.heroShieldAmount;
      }
    }

    // Wave management
    _waveTimer += dt;
    if (_enemiesSpawned < _enemiesThisWave && _spawnTimer <= 0) {
      _spawnEnemy();
      _spawnTimer = mode == GameMode.campaign ? 1.1 : 0.9;
    } else {
      _spawnTimer -= dt;
    }

    if (_enemiesSpawned >= _enemiesThisWave && enemies.isEmpty) {
      if (mode == GameMode.campaign &&
          currentCampaignLevel != null &&
          wave >= currentCampaignLevel!.waves) {
        _victory();
        return;
      }
      _nextWave();
    }

    // Move enemies toward center + slow effect
    for (final e in enemies) {
      if (!e.isAlive) continue;

      // Apply slow decay
      if (e.slowTimer > 0) {
        e.slowTimer -= dt;
        if (e.slowTimer <= 0) e.slowFactor = 1.0;
      }

      final dir = center - e.position;
      final dist = dir.distance;
      if (dist > 18) {
        final speed = e.data.speed * e.slowFactor;
        final move = dir / dist * speed * dt;
        e.position += move;
      } else {
        // Attack hero
        e.attackCooldown -= dt;
        if (e.attackCooldown <= 0) {
          double dmg = e.data.damage.toDouble();

          // Armor from hero
          if (hero != null && hero.heroArmor > 0) {
            dmg *= (1.0 - hero.heroArmor);
          }

          // Absorb by shield first
          if (heroShield > 0) {
            final absorbed = dmg.clamp(0, heroShield);
            heroShield -= absorbed;
            dmg -= absorbed;
          }

          heroHp -= dmg;
          e.attackCooldown = 1.0;
          if (heroHp <= 0) {
            heroHp = 0;
            _defeat();
            return;
          }
        }
      }
    }

    // Units move with their own animation phase. Mobile fighters patrol around
    // their deployment point; turrets/support units stay anchored but animate.
    for (final u in units) {
      u.animationPhase += dt * (1.8 + progress.player.unitSpeedLevel * 0.12);
      if (u.attackFlash > 0) u.attackFlash = (u.attackFlash - dt * 3.5).clamp(0.0, 1.0);
      if (u.type == UnitType.crawler || u.specialId != null || u.type == UnitType.robot ||
          u.type == UnitType.fireball) {
        final radius = u.type == UnitType.crawler ? 9.0 : 4.0;
        final base = u.movementTarget ?? u.position;
        u.movementTarget ??= base;
        // A small patrol arc gives each deployed fighter visible movement.
        final phase = u.animationPhase + (u.id.hashCode % 100) / 17.0;
        final target = Offset(base.dx + math.cos(phase) * radius,
            base.dy + math.sin(phase * 0.8) * radius);
        u.position = Offset(
          u.position.dx + (target.dx - u.position.dx) * (dt * (1.5 + progress.player.unitSpeedLevel * .1)).clamp(0.0, 1.0),
          u.position.dy + (target.dy - u.position.dy) * (dt * (1.5 + progress.player.unitSpeedLevel * .1)).clamp(0.0, 1.0),
        );
      }
    }

    // Units attack
    final unitsMult = hero?.heroUnitsDamageMult ?? 1.0;

    for (final u in units) {
      if (!u.isAlive) continue;
      u.cooldownTimer -= dt;
      if (u.cooldownTimer > 0) continue;

      final data = u.data;
      if (data.damage <= 0 && u.specialId == null) continue;

      double dmg = (u.specialId != null
              ? (getSpecialCharacter(u.specialId!)?.unitDamage ?? data.damage)
              : data.damage)
          .toDouble();

      // Boost from boost units + Overlord
      dmg *= unitsMult;
      for (final b in units.where((x) => x.type == UnitType.boost && x.isAlive)) {
        if ((u.position - b.position).distance < b.data.range) {
          dmg *= 1.4;
          break;
        }
      }

      Enemy? target;
      double bestDist = u.specialId != null
          ? (getSpecialCharacter(u.specialId!)?.unitRange ?? data.range)
          : data.range;

      for (final e in enemies) {
        if (!e.isAlive) continue;
        final d = (e.position - u.position).distance;
        if (d < bestDist) {
          bestDist = d;
          target = e;
        }
      }

      if (target != null) {
        _damageEnemy(target, dmg, applySlow: u.specialId == 'void_mage');
        u.attackFlash = 1.0;
        u.cooldownTimer = u.specialId != null
            ? (getSpecialCharacter(u.specialId!)?.unitCooldown ?? data.cooldown)
            : data.cooldown;
      }
    }

    // Clean dead
    enemies.removeWhere((e) => !e.isAlive);
    units.removeWhere((u) => !u.isAlive);

    notifyListeners();
  }

  void _nextWave() {
    wave++;
    _enemiesSpawned = 0;
    final base = mode == GameMode.campaign
        ? 4 + wave * (currentCampaignLevel?.enemyMultiplier ?? 1)
        : 3 + wave;
    _enemiesThisWave = base + _rng.nextInt(3);
    _spawnTimer = 0.5;
  }

  void _spawnEnemy() {
    final angle = _rng.nextDouble() * 2 * pi;
    final pos = Offset(
      center.dx + cos(angle) * (arenaRadius + 30),
      center.dy + sin(angle) * (arenaRadius + 30),
    );

    EnemyType type = EnemyType.basic;
    final r = _rng.nextDouble();
    if (wave >= 8 && r < 0.08) {
      type = EnemyType.boss;
    } else if (wave >= 4 && r < 0.25) {
      type = EnemyType.purple;
    } else if (wave >= 2 && r < 0.4) {
      type = EnemyType.red;
    }

    final data = enemyCatalog[type]!;
    final mult = mode == GameMode.campaign
        ? (currentCampaignLevel?.enemyMultiplier ?? 1).toDouble()
        : 1.0;

    enemies.add(Enemy(
      id: 'e_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      position: pos,
      currentHp: data.maxHp * mult,
    ));
    _enemiesSpawned++;
  }

  void _damageEnemy(Enemy e, double dmg, {bool applySlow = false}) {
    e.currentHp -= dmg;

    if (applySlow || (activeHero?.heroAppliesSlow == true)) {
      final hero = activeHero;
      e.slowFactor = hero?.heroSlowFactor ?? 0.5;
      e.slowTimer = hero?.heroSlowDuration ?? 2.0;
    }

    if (e.currentHp <= 0) {
      e.isAlive = false;
      kills++;
      coinsEarned += e.data.rewardCoins;
      progress.player.addXp(e.data.rewardXp);
      progress.player.addSeasonXp((e.data.rewardXp * 0.6).round());
      progress.addCoins(e.data.rewardCoins);
    }
  }

  // Player taps on an enemy
  void tapEnemy(Enemy e) {
    if (!isPlaying || isPaused || !e.isAlive) return;

    final hero = activeHero;
    double dmg = 18 + progress.player.level * 2.0 + progress.player.clickDamageLevel * 5.0;
    if (hero != null) {
      dmg *= hero.heroDamageMult;
    }

    _damageEnemy(e, dmg, applySlow: hero?.heroAppliesSlow == true);
    notifyListeners();
  }

  // Place normal unit
  void placeUnit(Offset localPos) {
    if (selectedUnitType == null || !isPlaying) return;

    final data = unitCatalog[selectedUnitType!]!;
    final key = selectedUnitType!.name;

    final count = progress.player.inventory[key] ?? 0;
    if (count <= 0) return;

    final distFromCenter = (localPos - center).distance;
    if (distFromCenter > arenaRadius - 20) return;

    progress.updatePlayer((p) {
      p.inventory[key] = (p.inventory[key] ?? 1) - 1;
    });

    units.add(PlacedUnit(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      type: selectedUnitType!,
      position: localPos,
      currentHp: data.hp.toDouble(),
    ));

    selectedUnitType = null;
    notifyListeners();
  }

  // Place special character as unit (hybrid)
  void placeSpecialUnit(Offset localPos) {
    if (selectedSpecialId == null || !isPlaying) return;

    final char = getSpecialCharacter(selectedSpecialId!);
    if (char == null) return;

    final count = progress.player.specialUnitCounts[selectedSpecialId!] ?? 0;
    if (count <= 0) return;

    final distFromCenter = (localPos - center).distance;
    if (distFromCenter > arenaRadius - 20) return;

    progress.updatePlayer((p) {
      p.specialUnitCounts[selectedSpecialId!] =
          (p.specialUnitCounts[selectedSpecialId!] ?? 1) - 1;
    });

    // Use a base type for rendering, but store specialId
    units.add(PlacedUnit(
      id: 's_${DateTime.now().microsecondsSinceEpoch}',
      type: UnitType.robot, // visual fallback
      position: localPos,
      currentHp: char.unitHp.toDouble(),
      specialId: selectedSpecialId,
    ));

    selectedSpecialId = null;
    notifyListeners();
  }

  void selectUnit(UnitType type) {
    final key = type.name;
    if ((progress.player.inventory[key] ?? 0) > 0) {
      selectedUnitType = type;
      selectedSpecialId = null;
      notifyListeners();
    }
  }

  void selectSpecialUnit(String id) {
    if ((progress.player.specialUnitCounts[id] ?? 0) > 0) {
      selectedSpecialId = id;
      selectedUnitType = null;
      notifyListeners();
    }
  }

  void _victory() {
    isPlaying = false;
    _gameTimer?.cancel();
    if (currentCampaignLevel != null) {
      final lvl = currentCampaignLevel!;
      progress.updatePlayer((p) {
        p.coins += lvl.rewardCoins;
        p.crystals += lvl.rewardCrystals;
        p.addXp(lvl.rewardXp);
        p.addSeasonXp(lvl.rewardXp);
        if (lvl.id >= p.campaignLevelUnlocked) {
          p.campaignLevelUnlocked = lvl.id + 1;
        }
      });
    }
    notifyListeners();
  }

  void _defeat() {
    isPlaying = false;
    _gameTimer?.cancel();
    progress.updatePlayer((p) {
      p.currentHp = heroHp;
      if (wave > p.highestWave) p.highestWave = wave;
    });
    notifyListeners();
  }

  void pause() {
    isPaused = true;
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    notifyListeners();
  }

  void stop() {
    isPlaying = false;
    _gameTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}