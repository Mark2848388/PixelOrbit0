import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/campaign.dart';
import '../services/progress_service.dart';
import '../services/game_service.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final unlocked = progress.player.campaignLevelUnlocked;

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
                        'КАМПАНИЯ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: campaignLevels.length,
                  itemBuilder: (context, i) {
                    final level = campaignLevels[i];
                    final isUnlocked = level.id <= unlocked;
                    final isCompleted = level.id < unlocked;

                    return Opacity(
                      opacity: isUnlocked ? 1 : 0.45,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.greenAccent.withOpacity(0.5)
                                : isUnlocked
                                    ? Colors.cyan.withOpacity(0.4)
                                    : Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked
                                  ? const Color(0xFF0F3460)
                                  : Colors.black26,
                              border: Border.all(
                                color: isCompleted
                                    ? Colors.greenAccent
                                    : Colors.cyan,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check,
                                      color: Colors.greenAccent, size: 24)
                                  : Text(
                                      '${level.id}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                            ),
                          ),
                          title: Text(
                            level.title,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                level.description,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Волн: ${level.waves}  •  Ур. ${level.recommendedLevel}+',
                                style: const TextStyle(
                                    fontSize: 8, color: Colors.white38),
                              ),
                            ],
                          ),
                          trailing: isUnlocked
                              ? ElevatedButton(
                                  onPressed: () {
                                    final game = context.read<GameService>();
                                    game.startCampaign(level);
                                    Navigator.pushNamed(context, '/game');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00C853),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text('Играть',
                                      style: TextStyle(fontSize: 9)),
                                )
                              : const Icon(Icons.lock,
                                  color: Colors.white24, size: 22),
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
}