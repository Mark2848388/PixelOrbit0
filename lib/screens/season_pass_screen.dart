import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/season.dart';
import '../services/progress_service.dart';

class SeasonPassScreen extends StatelessWidget {
  const SeasonPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final p = progress.player;
    final season = currentSeason;
    final daysLeft = season.endDate.difference(DateTime.now()).inDays.clamp(0, 999);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A0845), Color(0xFF1A1A2E), Color(0xFF0F0C29)],
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
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'СЕЗОН ${season.seasonNumber}',
                            style: const TextStyle(
                                fontSize: 12, letterSpacing: 2, color: Colors.amber),
                          ),
                          Text(
                            season.title,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Timer
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      daysLeft > 0
                          ? 'До конца сезона: $daysLeft дн. (1 декабря 2026)'
                          : 'Сезон завершён',
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Level progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Ур. ${p.seasonLevel}',
                      style: const TextStyle(fontSize: 11, color: Colors.amber),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (p.seasonXp / (p.seasonLevel * 150)).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${p.seasonXp}/${p.seasonLevel * 150}',
                      style: const TextStyle(fontSize: 9, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Premium toggle (mock)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.seasonPremium ? 'Premium активен' : 'Бесплатный пропуск',
                        style: TextStyle(
                          fontSize: 10,
                          color: p.seasonPremium ? Colors.amber : Colors.white54,
                        ),
                      ),
                    ),
                    if (!p.seasonPremium)
                      TextButton(
                        onPressed: () {
                          // Mock buy
                          progress.updatePlayer((player) {
                            if (player.crystals >= 80) {
                              player.crystals -= 80;
                              player.seasonPremium = true;
                            }
                          });
                        },
                        child: const Text(
                          'Купить Premium (80 💎)',
                          style: TextStyle(fontSize: 9, color: Colors.amber),
                        ),
                      ),
                  ],
                ),
              ),

              // Special characters (Hybrid)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Особые персонажи (Герой + Юнит)',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Тапни по разблокированному → сделать героем. Также можно ставить на поле.',
                  style: TextStyle(fontSize: 8, color: Colors.white38),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: season.specialCharacters.length + 1,
                  itemBuilder: (context, i) {
                    // Первый — обычный робот
                    if (i == 0) {
                      final isActive = p.activeHeroId == 'default';
                      return GestureDetector(
                        onTap: () => progress.setActiveHero('default'),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive ? Colors.cyan : Colors.white24,
                              width: isActive ? 2.5 : 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.smart_toy,
                                  color: isActive ? Colors.cyan : Colors.white54,
                                  size: 28),
                              const SizedBox(height: 6),
                              Text(
                                'Обычный робот',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isActive ? Colors.white : Colors.white54,
                                ),
                              ),
                              if (isActive)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('АКТИВЕН',
                                      style: TextStyle(
                                          fontSize: 7, color: Colors.cyan)),
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    final c = season.specialCharacters[i - 1];
                    final unlocked = p.unlockedCharacters.contains(c.id) ||
                        (p.seasonLevel >= c.requiredSeasonLevel &&
                            (!c.premiumOnly || p.seasonPremium));
                    final isActive = p.activeHeroId == c.id;
                    final unitCount = p.specialUnitCounts[c.id] ?? 0;

                    // Auto-unlock if level reached
                    if (unlocked && !p.unlockedCharacters.contains(c.id)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        progress.unlockCharacter(c.id);
                      });
                    }

                    return GestureDetector(
                      onTap: unlocked
                          ? () => progress.setActiveHero(c.id)
                          : null,
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? c.accentColor
                                : (unlocked ? c.accentColor.withOpacity(0.6) : Colors.white12),
                            width: isActive ? 2.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              unlocked ? c.icon : Icons.lock,
                              color: unlocked ? c.accentColor : Colors.white24,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: unlocked ? Colors.white : Colors.white38,
                              ),
                            ),
                            Text(
                              'Ур. ${c.requiredSeasonLevel}',
                              style: const TextStyle(
                                  fontSize: 7, color: Colors.white30),
                            ),
                            if (unlocked)
                              Text(
                                'Юнитов: $unitCount',
                                style: TextStyle(
                                    fontSize: 7, color: c.accentColor),
                              ),
                            if (isActive)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text('АКТИВЕН',
                                    style: TextStyle(
                                        fontSize: 7, color: c.accentColor)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Rewards list
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Награды сезона',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: season.rewards.length,
                  itemBuilder: (context, i) {
                    final r = season.rewards[i];
                    final reached = p.seasonLevel >= r.level;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: reached
                            ? Colors.green.withOpacity(0.1)
                            : Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: reached
                              ? Colors.greenAccent.withOpacity(0.4)
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: reached
                                  ? Colors.greenAccent.withOpacity(0.2)
                                  : Colors.white10,
                            ),
                            child: Center(
                              child: Text(
                                '${r.level}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: reached
                                      ? Colors.greenAccent
                                      : Colors.white38,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              r.freeReward,
                              style: TextStyle(
                                fontSize: 9,
                                color: reached ? Colors.white70 : Colors.white38,
                              ),
                            ),
                          ),
                          if (p.seasonPremium)
                            Expanded(
                              child: Text(
                                r.premiumReward,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: reached ? Colors.amber : Colors.white30,
                                ),
                              ),
                            )
                          else
                            const Icon(Icons.lock, size: 14, color: Colors.white24),
                        ],
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
}