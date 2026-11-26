import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/progress_service.dart';
import '../models/unit.dart';
import '../models/enemy.dart';
import '../models/season.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameService>();
      if (!game.isPlaying) {
        game.startEndless();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final progress = context.watch<ProgressService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top HUD
              _TopHud(game: game, progress: progress),
              // Arena
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        final local = details.localPosition;
                        // Check if tapped an enemy
                        for (final e in game.enemies) {
                          if (!e.isAlive) continue;
                          final d = (e.position - local).distance;
                          if (d < e.data.size + 12) {
                            game.tapEnemy(e);
                            return;
                          }
                        }
                        // Place normal or special unit
                        if (game.selectedUnitType != null) {
                          game.placeUnit(local);
                        } else if (game.selectedSpecialId != null) {
                          game.placeSpecialUnit(local);
                        }
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _ArenaPainter(game: game),
                        child: Stack(
                          children: [
                            // Hero in center
                            Positioned(
                              left: game.center.dx - 22,
                              top: game.center.dy - 22,
                              child: _HeroWidget(game: game),
                            ),
                            // Units
                            ...game.units.map((u) => Positioned(
                                  left: u.position.dx - 18,
                                  top: u.position.dy - 18,
                                  child: _UnitWidget(unit: u),
                                )),
                            // Enemies
                            ...game.enemies.map((e) => Positioned(
                                  left: e.position.dx - e.data.size / 2,
                                  top: e.position.dy - e.data.size / 2,
                                  child: _EnemyWidget(enemy: e),
                                )),
                            // Selected unit indicator
                            if (game.selectedUnitType != null ||
                                game.selectedSpecialId != null)
                              Positioned(
                                top: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.amber),
                                    ),
                                    child: Text(
                                      game.selectedSpecialId != null
                                          ? 'Тапни на арену: ${getSpecialCharacter(game.selectedSpecialId!)?.name ?? "Особый"}'
                                          : 'Тапни на арену: ${unitCatalog[game.selectedUnitType!]!.nameRu}',
                                      style: const TextStyle(
                                          fontSize: 9, color: Colors.amber),
                                    ),
                                  ),
                                ),
                              ),
                            // Pause / result overlays
                            if (!game.isPlaying)
                              _ResultOverlay(game: game),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Inventory
              _InventoryBar(game: game, progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  final GameService game;
  final ProgressService progress;
  const _TopHud({required this.game, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white70, size: 22),
            onPressed: () {
              game.stop();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 4),
          // HP
          const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: game.heroHp / game.heroMaxHp,
                minHeight: 12,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(
                  game.heroHp > game.heroMaxHp * 0.3
                      ? const Color(0xFF4CAF50)
                      : Colors.redAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Wave
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Волна ${game.wave}',
              style: const TextStyle(fontSize: 9, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          // Coins earned
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
              const SizedBox(width: 3),
              Text('${game.coinsEarned}',
                  style: const TextStyle(fontSize: 10, color: Colors.amber)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroWidget extends StatelessWidget {
  final GameService game;
  const _HeroWidget({required this.game});

  @override
  Widget build(BuildContext context) {
    final hero = game.activeHero;
    final color = hero?.accentColor ?? Colors.cyan;
    final icon = hero?.icon ?? Icons.smart_toy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (game.heroShield > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🛡 ${game.heroShield.toInt()}',
              style: const TextStyle(fontSize: 8, color: Colors.black),
            ),
          ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/sprites/robot.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitWidget extends StatelessWidget {
  final PlacedUnit unit;
  const _UnitWidget({required this.unit});

  @override
  Widget build(BuildContext context) {
    if (unit.specialId != null) {
      final char = getSpecialCharacter(unit.specialId!);
      if (char != null) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: char.accentColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: char.accentColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: char.accentColor.withOpacity(0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(char.icon, color: char.accentColor, size: 22),
        );
      }
    }

    final data = unit.data;
    String? sprite;
    switch (unit.type) {
      case UnitType.turret:
        sprite = 'assets/sprites/turret.png';
        break;
      case UnitType.shield:
        sprite = 'assets/sprites/shield.png';
        break;
      case UnitType.boost:
        sprite = 'assets/sprites/boost.png';
        break;
      case UnitType.fireball:
        sprite = 'assets/sprites/enemy_fire.png';
        break;
      default:
        sprite = 'assets/sprites/robot.png';
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: data.color, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          sprite,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(data.icon, color: data.color, size: 22),
        ),
      ),
    );
  }
}

class _EnemyWidget extends StatelessWidget {
  final Enemy enemy;
  const _EnemyWidget({required this.enemy});

  @override
  Widget build(BuildContext context) {
    final data = enemy.data;
    final hpRatio = enemy.currentHp / data.maxHp;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // HP bar
        Container(
          width: data.size,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: hpRatio.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: hpRatio > 0.4 ? data.color : Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: data.size + 8,
          height: data.size + 8,
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: data.color, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              enemy.type == EnemyType.red || enemy.type == EnemyType.boss
                  ? 'assets/sprites/enemy_fire.png'
                  : 'assets/sprites/enemy_green.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(data.icon, color: data.color, size: data.size * 0.55),
            ),
          ),
        ),
      ],
    );
  }
}

class _InventoryBar extends StatelessWidget {
  final GameService game;
  final ProgressService progress;
  const _InventoryBar({required this.game, required this.progress});

  @override
  Widget build(BuildContext context) {
    final specials = currentSeason.specialCharacters
        .where((c) => (progress.player.specialUnitCounts[c.id] ?? 0) > 0)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'ИНВЕНТАРЬ',
              style: TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 10),
          // Обычные юниты
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: UnitType.values.map((type) {
                final data = unitCatalog[type]!;
                final count = progress.player.inventory[type.name] ?? 0;
                final selected = game.selectedUnitType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      if (count > 0) game.selectUnit(type);
                    },
                    child: Opacity(
                      opacity: count > 0 ? 1 : 0.4,
                      child: Container(
                        width: 52,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? data.color.withOpacity(0.3)
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? data.color : Colors.white12,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(data.icon, color: data.color, size: 22),
                            const SizedBox(height: 3),
                            Text(
                              data.nameRu,
                              style: TextStyle(fontSize: 7, color: data.color),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: data.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(fontSize: 9, color: data.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Особые персонажи-юниты
          if (specials.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: specials.map((c) {
                  final count = progress.player.specialUnitCounts[c.id] ?? 0;
                  final selected = game.selectedSpecialId == c.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => game.selectSpecialUnit(c.id),
                      child: Container(
                        width: 56,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? c.accentColor.withOpacity(0.35)
                              : c.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? c.accentColor : c.accentColor.withOpacity(0.5),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(c.icon, color: c.accentColor, size: 22),
                            const SizedBox(height: 3),
                            Text(
                              c.name.split(' ').last,
                              style: TextStyle(fontSize: 7, color: c.accentColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: c.accentColor.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(fontSize: 9, color: c.accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  final GameService game;
  const _ResultOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    final won = game.heroHp > 0;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: won ? Colors.greenAccent : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events : Icons.heart_broken,
                size: 48,
                color: won ? Colors.amber : Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                won ? 'Победа!' : 'Поражение',
                style: TextStyle(
                  fontSize: 16,
                  color: won ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Волна: ${game.wave}   Убийств: ${game.kills}',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
              Text(
                '+${game.coinsEarned} монет',
                style: const TextStyle(fontSize: 11, color: Colors.amber),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      game.stop();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                    child: const Text('Меню', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      game.startEndless();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                    ),
                    child: const Text('Ещё раз', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  final GameService game;
  _ArenaPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Arena circle
    canvas.drawCircle(game.center, game.arenaRadius, paint);

    // Border
    final border = Paint()
      ..color = const Color(0xFF7B68EE).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(game.center, game.arenaRadius, border);

    // Grid dots
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.06);
    for (double x = 20; x < size.width; x += 28) {
      for (double y = 20; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}