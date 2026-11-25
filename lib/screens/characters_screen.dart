import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/characters.dart';
import '../services/progress_service.dart';

class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final p = progress.player;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'ПЕРСОНАЖИ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Active hero preview
              _ActiveHeroCard(progress: progress),

              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Коллекция',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Grid of characters
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allCharacters.length,
                  itemBuilder: (context, i) {
                    final c = allCharacters[i];
                    final unlocked = c.id == 'default' ||
                        p.unlockedCharacters.contains(c.id) ||
                        (!c.isSeasonal) || // non-seasonal can be unlocked later
                        (c.isSeasonal &&
                            p.seasonLevel >= c.requiredSeasonLevel &&
                            (!c.premiumOnly || p.seasonPremium));

                    // Auto unlock seasonal if level reached
                    if (c.isSeasonal &&
                        unlocked &&
                        !p.unlockedCharacters.contains(c.id)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        progress.unlockCharacter(c.id);
                      });
                    }

                    final isActive = p.activeHeroId == c.id;
                    final unitCount = p.specialUnitCounts[c.id] ?? 0;

                    return GestureDetector(
                      onTap: unlocked
                          ? () => _showCharacterDetail(context, c, progress)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? c.accentColor
                                : (unlocked
                                    ? c.accentColor.withOpacity(0.5)
                                    : Colors.white12),
                            width: isActive ? 2.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Image / Icon
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: unlocked && c.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          c.imagePath!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Icon(
                                            c.icon,
                                            size: 48,
                                            color: c.accentColor,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        unlocked ? c.icon : Icons.lock,
                                        size: 48,
                                        color: unlocked
                                            ? c.accentColor
                                            : Colors.white24,
                                      ),
                              ),
                            ),
                            // Info
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                              child: Column(
                                children: [
                                  Text(
                                    c.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: unlocked
                                          ? Colors.white
                                          : Colors.white38,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  _RarityChip(c.rarity),
                                  if (unlocked && unitCount > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        'Юнитов: $unitCount',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: c.accentColor,
                                        ),
                                      ),
                                    ),
                                  if (isActive)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        'АКТИВЕН',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: c.accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (!unlocked && c.isSeasonal)
                                    Text(
                                      'Сезон ур. ${c.requiredSeasonLevel}',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.white30,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCharacterDetail(
      BuildContext context, GameCharacter c, ProgressService progress) {
    final p = progress.player;
    final isActive = p.activeHeroId == c.id;
    final unitCount = p.specialUnitCounts[c.id] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (c.imagePath != null)
                SizedBox(
                  height: 140,
                  child: Image.asset(
                    c.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(c.icon, size: 80, color: c.accentColor),
                  ),
                )
              else
                Icon(c.icon, size: 80, color: c.accentColor),
              const SizedBox(height: 12),
              Text(
                c.name,
                style: TextStyle(fontSize: 16, color: c.accentColor),
              ),
              const SizedBox(height: 6),
              _RarityChip(c.rarity),
              const SizedBox(height: 10),
              Text(
                c.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat('Урон', '${c.unitDamage}'),
                  _Stat('HP', '${c.unitHp}'),
                  _Stat('Кулдаун', '${c.unitCooldown}с'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isActive
                          ? null
                          : () {
                              progress.setActiveHero(c.id);
                              Navigator.pop(ctx);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accentColor,
                        disabledBackgroundColor: Colors.white12,
                      ),
                      child: Text(
                        isActive ? 'Уже герой' : 'Сделать героем',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (unitCount > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.accentColor),
                        ),
                        child: Text(
                          'Юнитов: $unitCount',
                          style: TextStyle(fontSize: 11, color: c.accentColor),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveHeroCard extends StatelessWidget {
  final ProgressService progress;
  const _ActiveHeroCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final c = getCharacter(progress.player.activeHeroId) ?? allCharacters.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accentColor.withOpacity(0.25),
            c.accentColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.accentColor.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: c.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      c.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(c.icon, color: c.accentColor, size: 32),
                    ),
                  )
                : Icon(c.icon, color: c.accentColor, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Активный герой',
                  style: TextStyle(fontSize: 9, color: Colors.white54),
                ),
                const SizedBox(height: 3),
                Text(
                  c.name,
                  style: TextStyle(fontSize: 13, color: c.accentColor),
                ),
                const SizedBox(height: 3),
                Text(
                  c.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final String rarity;
  const _RarityChip(this.rarity);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (rarity) {
      case 'legendary':
        color = const Color(0xFFFFD700);
        break;
      case 'epic':
        color = const Color(0xFFAB47BC);
        break;
      case 'rare':
        color = const Color(0xFF42A5F5);
        break;
      default:
        color = Colors.white54;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: TextStyle(fontSize: 8, color: color),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white54)),
      ],
    );
  }
}