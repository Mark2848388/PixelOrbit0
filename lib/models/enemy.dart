import 'package:flutter/material.dart';

enum EnemyType {
  basic,    // зелёный ползун
  red,      // красный
  purple,   // фиолетовый глаз
  boss,
}

class EnemyData {
  final EnemyType type;
  final String name;
  final double speed;
  final int maxHp;
  final int damage;
  final int rewardCoins;
  final int rewardXp;
  final Color color;
  final IconData icon;
  final double size;

  const EnemyData({
    required this.type,
    required this.name,
    required this.speed,
    required this.maxHp,
    required this.damage,
    required this.rewardCoins,
    required this.rewardXp,
    required this.color,
    required this.icon,
    required this.size,
  });
}

const Map<EnemyType, EnemyData> enemyCatalog = {
  EnemyType.basic: EnemyData(
    type: EnemyType.basic,
    name: 'Ползун',
    speed: 40,
    maxHp: 40,
    damage: 5,
    rewardCoins: 3,
    rewardXp: 5,
    color: Color(0xFF4CAF50),
    icon: Icons.bug_report,
    size: 28,
  ),
  EnemyType.red: EnemyData(
    type: EnemyType.red,
    name: 'Огненный',
    speed: 55,
    maxHp: 25,
    damage: 8,
    rewardCoins: 5,
    rewardXp: 8,
    color: Color(0xFFE53935),
    icon: Icons.whatshot,
    size: 26,
  ),
  EnemyType.purple: EnemyData(
    type: EnemyType.purple,
    name: 'Глаз',
    speed: 30,
    maxHp: 80,
    damage: 12,
    rewardCoins: 10,
    rewardXp: 15,
    color: Color(0xFF9C27B0),
    icon: Icons.visibility,
    size: 32,
  ),
  EnemyType.boss: EnemyData(
    type: EnemyType.boss,
    name: 'Босс',
    speed: 20,
    maxHp: 400,
    damage: 25,
    rewardCoins: 50,
    rewardXp: 80,
    color: Color(0xFFFF5722),
    icon: Icons.dangerous,
    size: 48,
  ),
};

class Enemy {
  final String id;
  final EnemyType type;
  Offset position;
  double currentHp;
  bool isAlive;
  double attackCooldown;
  double slowFactor;
  double slowTimer;

  Enemy({
    required this.id,
    required this.type,
    required this.position,
    required this.currentHp,
    this.isAlive = true,
    this.attackCooldown = 0,
    this.slowFactor = 1.0,
    this.slowTimer = 0,
  });

  EnemyData get data => enemyCatalog[type]!;
}