import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../models/season.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final p = progress.player;
    final season = currentSeason;
    final daysLeft = season.endDate.difference(DateTime.now()).inDays;

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
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyan, width: 2),
                        color: const Color(0xFF0F3460),
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.cyan, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Ур ${p.level}',
                                  style: const TextStyle(fontSize: 9, color: Colors.white70)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: p.xp / p.maxXp,
                                    minHeight: 8,
                                    backgroundColor: Colors.white12,
                                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Currencies
                    _CurrencyChip(Icons.monetization_on, p.coins, Colors.amber),
                    const SizedBox(width: 8),
                    _CurrencyChip(Icons.diamond, p.crystals, Colors.purpleAccent),
                  ],
                ),
              ),

              // Time
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wb_sunny, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      TimeOfDay.now().format(context),
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // Main buttons grid
                      Row(
                        children: [
                          Expanded(
                            child: _MenuButton(
                              icon: Icons.store,
                              label: 'Магазин',
                              color: const Color(0xFFFF9800),
                              onTap: () => Navigator.pushNamed(context, '/hub'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuButton(
                              icon: Icons.public,
                              label: 'Миры',
                              color: const Color(0xFF2196F3),
                              onTap: () => Navigator.pushNamed(context, '/campaign'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuButton(
                              icon: Icons.assignment,
                              label: 'Квесты',
                              color: const Color(0xFF8BC34A),
                              onTap: () => Navigator.pushNamed(context, '/hub'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MenuButton(
                              icon: Icons.settings,
                              label: 'Настройки',
                              color: const Color(0xFF607D8B),
                              onTap: () => Navigator.pushNamed(context, '/hub'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuButton(
                              icon: Icons.sports_esports,
                              label: 'Режимы',
                              color: const Color(0xFF4CAF50),
                              onTap: () {
                                Navigator.pushNamed(context, '/game');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuButton(
                              icon: Icons.people,
                              label: 'Персонажи',
                              color: const Color(0xFFE91E63),
                              onTap: () {
                                Navigator.pushNamed(context, '/characters');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Season Pass card
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/season'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.purpleAccent, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black26,
                                  border: Border.all(color: Colors.amber, width: 2),
                                ),
                                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Сезон ${season.seasonNumber}: ${season.title}',
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      daysLeft > 0
                                          ? 'Осталось $daysLeft дн. (до 1 дек)'
                                          : 'Сезон завершён',
                                      style: const TextStyle(fontSize: 9, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: p.seasonLevel / 50,
                                        minHeight: 6,
                                        backgroundColor: Colors.white12,
                                        valueColor: const AlwaysStoppedAnimation(Colors.amber),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Play button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/game'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, size: 28),
                              SizedBox(width: 8),
                              Text('ИГРАТЬ', style: TextStyle(fontSize: 14, letterSpacing: 2)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Friends bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Text('Друзья', style: TextStyle(fontSize: 10, color: Colors.white70)),
                            const SizedBox(width: 12),
                            _FriendAvatar(Colors.blue),
                            const SizedBox(width: 6),
                            _FriendAvatar(Colors.green),
                            const SizedBox(width: 6),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 1.5),
                                color: Colors.white10,
                              ),
                              child: const Icon(Icons.add, size: 18, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Скоро будет доступно!', style: TextStyle(fontSize: 11)),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  const _CurrencyChip(this.icon, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text('$value', style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 9, color: color)),
          ],
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final Color color;
  const _FriendAvatar(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.3),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(Icons.person, size: 18, color: color),
    );
  }
}