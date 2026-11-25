class CampaignLevel {
  final int id;
  final String title;
  final String description;
  final int recommendedLevel;
  final int waves;
  final int enemyMultiplier;
  final bool hasBoss;
  final int rewardCoins;
  final int rewardCrystals;
  final int rewardXp;

  const CampaignLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.recommendedLevel,
    required this.waves,
    required this.enemyMultiplier,
    required this.hasBoss,
    required this.rewardCoins,
    required this.rewardCrystals,
    required this.rewardXp,
  });
}

const List<CampaignLevel> campaignLevels = [
  CampaignLevel(
    id: 1,
    title: 'Первый контакт',
    description: 'Отразите первую волну захватчиков.',
    recommendedLevel: 1,
    waves: 5,
    enemyMultiplier: 1,
    hasBoss: false,
    rewardCoins: 80,
    rewardCrystals: 5,
    rewardXp: 40,
  ),
  CampaignLevel(
    id: 2,
    title: 'Орбитальная станция',
    description: 'Защитите станцию от ползунов.',
    recommendedLevel: 2,
    waves: 7,
    enemyMultiplier: 1,
    hasBoss: false,
    rewardCoins: 120,
    rewardCrystals: 8,
    rewardXp: 60,
  ),
  CampaignLevel(
    id: 3,
    title: 'Красная угроза',
    description: 'Появились быстрые огненные враги.',
    recommendedLevel: 3,
    waves: 8,
    enemyMultiplier: 1,
    hasBoss: true,
    rewardCoins: 180,
    rewardCrystals: 12,
    rewardXp: 90,
  ),
  CampaignLevel(
    id: 4,
    title: 'Глаза в темноте',
    description: 'Фиолетовые глаза следят за тобой.',
    recommendedLevel: 5,
    waves: 10,
    enemyMultiplier: 2,
    hasBoss: true,
    rewardCoins: 250,
    rewardCrystals: 18,
    rewardXp: 130,
  ),
  CampaignLevel(
    id: 5,
    title: 'Штурм',
    description: 'Массированная атака. Выдержи все волны.',
    recommendedLevel: 7,
    waves: 12,
    enemyMultiplier: 2,
    hasBoss: true,
    rewardCoins: 350,
    rewardCrystals: 25,
    rewardXp: 180,
  ),
  CampaignLevel(
    id: 6,
    title: 'Ядро планеты',
    description: 'Финальная битва первого сезона.',
    recommendedLevel: 10,
    waves: 15,
    enemyMultiplier: 3,
    hasBoss: true,
    rewardCoins: 500,
    rewardCrystals: 40,
    rewardXp: 300,
  ),
];