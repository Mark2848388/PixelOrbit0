class Player {
  String name;
  int level;
  int xp;
  int maxXp;
  int coins;
  int crystals;
  double maxHp;
  double currentHp;
  int energy;
  int maxEnergy;

  // Inventory counts (обычные юниты)
  Map<String, int> inventory;

  // Unlocked special characters from season pass
  List<String> unlockedCharacters;

  // Активный герой (id из specialCharacters или 'default')
  String activeHeroId;

  // Количество доступных особых юнитов (гибрид)
  Map<String, int> specialUnitCounts;

  // Campaign progress
  int campaignLevelUnlocked;
  int highestWave;

  // Season pass
  int seasonXp;
  int seasonLevel;
  bool seasonPremium;
  int clickDamageLevel;
  int unitSpeedLevel;
  int healthLevel;
  int energyLevel;
  List<String> claimedQuests;
  bool soundEnabled;
  bool vibrationEnabled;
  String language;

  Player({
    this.name = 'Герой',
    this.level = 1,
    this.xp = 0,
    this.maxXp = 100,
    this.coins = 100,
    this.crystals = 20,
    this.maxHp = 100,
    this.currentHp = 100,
    this.energy = 50,
    this.maxEnergy = 50,
    Map<String, int>? inventory,
    List<String>? unlockedCharacters,
    this.activeHeroId = 'default',
    Map<String, int>? specialUnitCounts,
    this.campaignLevelUnlocked = 1,
    this.highestWave = 0,
    this.seasonXp = 0,
    this.seasonLevel = 1,
    this.seasonPremium = false,
    this.clickDamageLevel = 0,
    this.unitSpeedLevel = 0,
    this.healthLevel = 0,
    this.energyLevel = 0,
    List<String>? claimedQuests,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'Русский',
  })  : inventory = inventory ??
            {
              'robot': 1,
              'turret': 2,
              'crawler': 1,
              'fireball': 1,
              'shield': 1,
              'boost': 1,
            },
        unlockedCharacters = unlockedCharacters ?? ['default'],
        specialUnitCounts = specialUnitCounts ?? {},
        claimedQuests = claimedQuests ?? [];

  void addXp(int amount) {
    xp += amount;
    while (xp >= maxXp) {
      xp -= maxXp;
      level++;
      maxXp = (maxXp * 1.35).round();
      maxHp += 15;
      currentHp = maxHp;
      coins += 25;
    }
  }

  void addSeasonXp(int amount) {
    seasonXp += amount;
    while (seasonXp >= seasonLevel * 150) {
      seasonXp -= seasonLevel * 150;
      seasonLevel++;
    }
  }

  bool isCharacterUnlocked(String id) {
    if (id == 'default') return true;
    return unlockedCharacters.contains(id);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'xp': xp,
        'maxXp': maxXp,
        'coins': coins,
        'crystals': crystals,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'energy': energy,
        'maxEnergy': maxEnergy,
        'inventory': inventory,
        'unlockedCharacters': unlockedCharacters,
        'activeHeroId': activeHeroId,
        'specialUnitCounts': specialUnitCounts,
        'campaignLevelUnlocked': campaignLevelUnlocked,
        'highestWave': highestWave,
        'seasonXp': seasonXp,
        'seasonLevel': seasonLevel,
        'seasonPremium': seasonPremium,
        'clickDamageLevel': clickDamageLevel,
        'unitSpeedLevel': unitSpeedLevel,
        'healthLevel': healthLevel,
        'energyLevel': energyLevel,
        'claimedQuests': claimedQuests,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'language': language,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] ?? 'Герой',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      maxXp: json['maxXp'] ?? 100,
      coins: json['coins'] ?? 100,
      crystals: json['crystals'] ?? 20,
      maxHp: (json['maxHp'] ?? 100).toDouble(),
      currentHp: (json['currentHp'] ?? 100).toDouble(),
      energy: json['energy'] ?? 50,
      maxEnergy: json['maxEnergy'] ?? 50,
      inventory: Map<String, int>.from(json['inventory'] ?? {}),
      unlockedCharacters:
          List<String>.from(json['unlockedCharacters'] ?? ['default']),
      activeHeroId: json['activeHeroId'] ?? 'default',
      specialUnitCounts:
          Map<String, int>.from(json['specialUnitCounts'] ?? {}),
      campaignLevelUnlocked: json['campaignLevelUnlocked'] ?? 1,
      highestWave: json['highestWave'] ?? 0,
      seasonXp: json['seasonXp'] ?? 0,
      seasonLevel: json['seasonLevel'] ?? 1,
      seasonPremium: json['seasonPremium'] ?? false,
      clickDamageLevel: json['clickDamageLevel'] ?? 0,
      unitSpeedLevel: json['unitSpeedLevel'] ?? 0,
      healthLevel: json['healthLevel'] ?? 0,
      energyLevel: json['energyLevel'] ?? 0,
      claimedQuests: List<String>.from(json['claimedQuests'] ?? []),
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      language: json['language'] ?? 'Русский',
    );
  }
}