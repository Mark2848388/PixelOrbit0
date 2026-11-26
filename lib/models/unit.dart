import 'package:flutter/material.dart';

enum UnitType {
  robot,
  turret,
  crawler,   // ползун
  fireball,  // огневик
  shield,
  boost,     // усиление
}

class UnitData {
  final UnitType type;
  final String nameRu;
  final String nameEn;
  final int cost;
  final int damage;
  final double range;
  final double cooldown;
  final int hp;
  final Color color;
  final IconData icon;
  final String description;

  const UnitData({
    required this.type,
    required this.nameRu,
    required this.nameEn,
    required this.cost,
    required this.damage,
    required this.range,
    required this.cooldown,
    required this.hp,
    required this.color,
    required this.icon,
    required this.description,
  });
}

const Map<UnitType, UnitData> unitCatalog = {
  UnitType.robot: UnitData(
    type: UnitType.robot,
    nameRu: 'Робот',
    nameEn: 'Robot',
    cost: 50,
    damage: 15,
    range: 120,
    cooldown: 0.8,
    hp: 80,
    color: Color(0xFF4FC3F7),
    icon: Icons.smart_toy,
    description: 'Дополнительный боец. Стреляет по ближайшим врагам.',
  ),
  UnitType.turret: UnitData(
    type: UnitType.turret,
    nameRu: 'Турелька',
    nameEn: 'Turret',
    cost: 30,
    damage: 12,
    range: 150,
    cooldown: 0.6,
    hp: 60,
    color: Color(0xFF9C27B0),
    icon: Icons.gps_fixed,
    description: 'Стационарная турель. Быстро стреляет на среднюю дистанцию.',
  ),
  UnitType.crawler: UnitData(
    type: UnitType.crawler,
    nameRu: 'Ползун',
    nameEn: 'Crawler',
    cost: 40,
    damage: 8,
    range: 80,
    cooldown: 0.4,
    hp: 100,
    color: Color(0xFF4CAF50),
    icon: Icons.bug_report,
    description: 'Быстрый ближний боец. Высокий урон вблизи.',
  ),
  UnitType.fireball: UnitData(
    type: UnitType.fireball,
    nameRu: 'Огневик',
    nameEn: 'Fireball',
    cost: 60,
    damage: 25,
    range: 100,
    cooldown: 1.2,
    hp: 40,
    color: Color(0xFFFF5722),
    icon: Icons.local_fire_department,
    description: 'Область урона. Поджигает группу врагов.',
  ),
  UnitType.shield: UnitData(
    type: UnitType.shield,
    nameRu: 'Щит',
    nameEn: 'Shield',
    cost: 70,
    damage: 0,
    range: 90,
    cooldown: 0,
    hp: 200,
    color: Color(0xFF2196F3),
    icon: Icons.shield,
    description: 'Защищает зону. Блокирует урон по главному герою.',
  ),
  UnitType.boost: UnitData(
    type: UnitType.boost,
    nameRu: 'Усиление',
    nameEn: 'Boost',
    cost: 45,
    damage: 0,
    range: 110,
    cooldown: 0,
    hp: 30,
    color: Color(0xFFFFC107),
    icon: Icons.star,
    description: 'Увеличивает урон всех юнитов в радиусе на 40%.',
  ),
};

class PlacedUnit {
  final String id;
  final UnitType type;
  Offset position;
  double currentHp;
  double cooldownTimer;
  bool isAlive;
  String? specialId; // если это персонаж сезона

  PlacedUnit({
    required this.id,
    required this.type,
    required this.position,
    required this.currentHp,
    this.cooldownTimer = 0,
    this.isAlive = true,
    this.specialId,
  });

  UnitData get data => unitCatalog[type]!;
}