import 'package:flutter/material.dart';

class SeasonReward {
  final int level;
  final String freeReward;
  final String premiumReward;
  final bool isCharacter;

  const SeasonReward({
    required this.level,
    required this.freeReward,
    required this.premiumReward,
    this.isCharacter = false,
  });
}

class SeasonData {
  final int seasonNumber;
  final String title;
  final DateTime endDate;
  final List<SeasonReward> rewards;
  final List<SpecialCharacter> specialCharacters;

  const SeasonData({
    required this.seasonNumber,
    required this.title,
    required this.endDate,
    required this.rewards,
    required this.specialCharacters,
  });
}

/// Гибридный персонаж сезона:
/// 1. Можно выбрать как главного героя (пассивные бонусы)
/// 2. Можно ставить как сильного юнита на поле (дороже обычных)
class SpecialCharacter {
  final String id;
  final String name;
  final String description;
  final int requiredSeasonLevel;
  final bool premiumOnly;
  final Color accentColor;
  final IconData icon;

  // --- Hero bonuses (когда выбран главным) ---
  final double heroDamageMult;   // множитель урона клика
  final double heroArmor;        // % снижения входящего урона
  final bool heroAppliesSlow;    // клики замедляют
  final double heroSlowFactor;   // во сколько раз замедляет
  final double heroSlowDuration;
  final bool heroPeriodicShield; // щит каждые N сек
  final double heroShieldInterval;
  final double heroShieldAmount;
  final double heroUnitsDamageMult; // бонус всем юнитам

  // --- Unit stats (когда ставится на поле) ---
  final int unitCost;
  final int unitDamage;
  final double unitRange;
  final double unitCooldown;
  final int unitHp;

  const SpecialCharacter({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredSeasonLevel,
    required this.premiumOnly,
    required this.accentColor,
    required this.icon,
    this.heroDamageMult = 1.0,
    this.heroArmor = 0.0,
    this.heroAppliesSlow = false,
    this.heroSlowFactor = 0.5,
    this.heroSlowDuration = 2.0,
    this.heroPeriodicShield = false,
    this.heroShieldInterval = 15.0,
    this.heroShieldAmount = 40.0,
    this.heroUnitsDamageMult = 1.0,
    required this.unitCost,
    required this.unitDamage,
    required this.unitRange,
    required this.unitCooldown,
    required this.unitHp,
  });
}

// Season 1 ends 1 December 2026
final SeasonData currentSeason = SeasonData(
  seasonNumber: 1,
  title: 'Прибытие',
  endDate: DateTime(2026, 12, 1, 23, 59, 59),
  specialCharacters: const [
    SpecialCharacter(
      id: 'cyber_knight',
      name: 'Кибер-Рыцарь',
      description: 'Урон +25%, броня 20%. Как юнит — танк с хорошим уроном.',
      requiredSeasonLevel: 5,
      premiumOnly: false,
      accentColor: Color(0xFF00BCD4),
      icon: Icons.shield_moon,
      heroDamageMult: 1.25,
      heroArmor: 0.20,
      unitCost: 90,
      unitDamage: 22,
      unitRange: 110,
      unitCooldown: 0.7,
      unitHp: 160,
    ),
    SpecialCharacter(
      id: 'void_mage',
      name: 'Маг Пустоты',
      description: 'Клики замедляют врагов. Как юнит — накладывает сильный slow.',
      requiredSeasonLevel: 15,
      premiumOnly: true,
      accentColor: Color(0xFF9C27B0),
      icon: Icons.auto_fix,
      heroAppliesSlow: true,
      heroSlowFactor: 0.45,
      heroSlowDuration: 2.5,
      unitCost: 110,
      unitDamage: 18,
      unitRange: 140,
      unitCooldown: 0.9,
      unitHp: 70,
    ),
    SpecialCharacter(
      id: 'nova_guardian',
      name: 'Страж Новы',
      description: 'Каждые 15 сек даёт щит. Как юнит — мощный защитник зоны.',
      requiredSeasonLevel: 25,
      premiumOnly: true,
      accentColor: Color(0xFFFFC107),
      icon: Icons.brightness_7,
      heroPeriodicShield: true,
      heroShieldInterval: 15.0,
      heroShieldAmount: 50.0,
      unitCost: 130,
      unitDamage: 10,
      unitRange: 100,
      unitCooldown: 1.1,
      unitHp: 220,
    ),
    SpecialCharacter(
      id: 'pixel_overlord',
      name: 'Пиксель-Оверлорд',
      description: 'Все юниты +40% урона. Как юнит — самый сильный боец.',
      requiredSeasonLevel: 40,
      premiumOnly: true,
      accentColor: Color(0xFFE91E63),
      icon: Icons.diamond,
      heroUnitsDamageMult: 1.40,
      heroDamageMult: 1.15,
      unitCost: 160,
      unitDamage: 35,
      unitRange: 130,
      unitCooldown: 0.55,
      unitHp: 140,
    ),
  ],
  rewards: [
    for (int i = 1; i <= 50; i++)
      SeasonReward(
        level: i,
        freeReward: i % 5 == 0 ? '50 кристаллов' : '${20 + i * 3} монет',
        premiumReward: i % 10 == 0
            ? (i == 10
                ? 'Кибер-Рыцарь'
                : i == 20
                    ? 'Маг Пустоты'
                    : i == 30
                        ? 'Страж Новы'
                        : 'Пиксель-Оверлорд')
            : '${40 + i * 5} монет + 10 кристаллов',
        isCharacter: i % 10 == 0,
      ),
  ],
);

/// Быстрый доступ по id
SpecialCharacter? getSpecialCharacter(String id) {
  try {
    return currentSeason.specialCharacters.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}