import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../models/unit.dart';
import '../models/season.dart';
import '../models/player.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});
  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 5, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProgressService>();
    final p = service.player;
    return Scaffold(
      appBar: AppBar(title: const Text('ЦЕНТР КОМАНДОВАНИЯ', style: TextStyle(fontSize: 12)),
        bottom: TabBar(controller: _tabs, isScrollable: true, tabs: const [
          Tab(icon: Icon(Icons.store), text: 'Магазин'),
          Tab(icon: Icon(Icons.assignment), text: 'Квесты'),
          Tab(icon: Icon(Icons.upgrade), text: 'Прокачка'),
          Tab(icon: Icon(Icons.tune), text: 'Настройки'),
          Tab(icon: Icon(Icons.leaderboard), text: 'Рейтинг'),
        ])),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF17152F), Color(0xFF092C50)])),
        child: TabBarView(controller: _tabs, children: [
          _shop(context, service),
          _quests(context, service),
          _upgrades(context, service),
          _settings(context, service),
          _leaderboard(context, service),
        ]),
      ),
    );
  }

  Widget _shop(BuildContext context, ProgressService s) {
    final p=s.player;
    return ListView(padding: const EdgeInsets.all(14), children: [
      _wallet(p.coins,p.crystals,p.energy),
      const SizedBox(height: 10),
      const Text('ОБЫЧНЫЕ ЮНИТЫ', style: TextStyle(color: Colors.cyan,fontSize:11)),
      ...unitCatalog.values.where((u)=>u.type!=UnitType.shield && u.type!=UnitType.boost).map((u)=>
        _item(u.icon,u.nameRu,u.description,'${u.cost} монет',()=>_buy(s,u.cost,()=>s.updatePlayer((p)=>p.inventory[u.type.name]=(p.inventory[u.type.name]??0)+1)))),
      const SizedBox(height: 8),
      const Text('ОСОБЫЕ ПЕРСОНАЖИ',style:TextStyle(color:Colors.purpleAccent,fontSize:11)),
      ...currentSeason.specialCharacters.map((c)=>_item(c.icon,c.name,'Уникальный боец · ${c.unitDamage} урона','${(p.unlockedCharacters.contains(c.id)?35:120)} кристаллов',(){
        if(p.unlockedCharacters.contains(c.id)) {
          _buyCrystal(s,35,()=>s.addSpecialUnit(c.id,1));
        } else {
          _buyCrystal(s,120,()=>s.unlockCharacter(c.id));
        }
      })),
      const SizedBox(height: 8),
      const Text('РЕСУРСЫ',style:TextStyle(color:Colors.amber,fontSize:11)),
      _item(Icons.diamond,'Кристаллы ×10','Премиальная валюта','100 монет',()=>_buy(s,100,()=>s.addCrystals(10))),
      _item(Icons.bolt,'Энергия +10','Восстанавливает запас энергии','50 монет',()=>_buy(s,50,()=>s.updatePlayer((p)=>p.energy=(p.energy+10).clamp(0,p.maxEnergy)))),
    ]);
  }

  Widget _quests(BuildContext context, ProgressService s) {
    final p=s.player;
    final quests=[
      ['daily_tap','Охотник','Уничтожь 10 врагов','+100 монет',10],
      ['daily_deploy','Командир','Размести 3 юнита','+5 кристаллов',3],
      ['daily_wave','Выживший','Достигни 5-й волны','+150 монет',5],
      ['season_kills','Сезонный вызов','Уничтожь 50 врагов за сезон','+20 кристаллов',50],
    ];
    return ListView(padding:const EdgeInsets.all(14),children:[
      const Text('ЕЖЕДНЕВНЫЕ И СЕЗОННЫЕ ЗАДАНИЯ',style:TextStyle(color:Colors.cyan,fontSize:10)),
      const SizedBox(height:10),
      ...quests.map((q){
        final done=p.claimedQuests.contains(q[0] as String);
        final season=(q[0] as String).startsWith('season');
        final progress=season?p.highestWave*5:p.highestWave;
        return Card(color:const Color(0xFF202447),child:ListTile(
          leading:Icon(season?Icons.stars:Icons.task_alt,color:season?Colors.amber:Colors.lightGreen),
          title:Text(q[1] as String,style:const TextStyle(fontSize:10)),
          subtitle:Text('${q[2]}  ·  ${q[3]}',style:const TextStyle(fontSize:8,color:Colors.white70)),
          trailing:done?const Icon(Icons.check_circle,color:Colors.green):TextButton(
            onPressed:()=>_claimQuest(s,q[0] as String,season),
            child:const Text('ЗАБРАТЬ',style:TextStyle(fontSize:8))),
        ));
      }),
      const Text('Награды выдаются один раз за период. Ежедневные задания обновляются при следующем ежедневном сбросе.',style:TextStyle(fontSize:8,color:Colors.white54)),
    ]);
  }

  Widget _upgrades(BuildContext context, ProgressService s) {
    final p=s.player;
    return ListView(padding:const EdgeInsets.all(14),children:[
      const Text('УЛУЧШЕНИЯ КОМАНДЫ',style:TextStyle(color:Colors.cyan,fontSize:11)),
      _upgrade(Icons.touch_app,'Урон клика','+5 урона за уровень',p.clickDamageLevel,()=>_upgradeBuy(s,0)),
      _upgrade(Icons.favorite,'Здоровье','+20 максимального здоровья',p.healthLevel,()=>_upgradeBuy(s,1)),
      _upgrade(Icons.speed,'Скорость юнитов','Быстрее перемещаются и атакуют',p.unitSpeedLevel,()=>_upgradeBuy(s,2)),
      _upgrade(Icons.bolt,'Запас энергии','+10 к максимальной энергии',p.energyLevel,()=>_upgradeBuy(s,3)),
    ]);
  }

  Widget _settings(BuildContext context, ProgressService s) {
    final p=s.player;
    return ListView(padding:const EdgeInsets.all(14),children:[
      SwitchListTile(title:const Text('Звуковые эффекты',style:TextStyle(fontSize:10)),value:p.soundEnabled,onChanged:(v)=>s.updatePlayer((p)=>p.soundEnabled=v)),
      SwitchListTile(title:const Text('Вибрация',style:TextStyle(fontSize:10)),value:p.vibrationEnabled,onChanged:(v)=>s.updatePlayer((p)=>p.vibrationEnabled=v)),
      ListTile(title:const Text('Язык',style:TextStyle(fontSize:10)),subtitle:Text(p.language,style:const TextStyle(fontSize:9)),trailing:DropdownButton<String>(value:p.language,items:const [DropdownMenuItem(value:'Русский',child:Text('Русский')),DropdownMenuItem(value:'English',child:Text('English'))],onChanged:(v){if(v!=null)s.updatePlayer((p)=>p.language=v);})),
      const Divider(),
      ListTile(leading:const Icon(Icons.restart_alt,color:Colors.redAccent),title:const Text('Сбросить прогресс',style:TextStyle(fontSize:10,color:Colors.redAccent)),onTap:()=>showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Сбросить прогресс?'),content:const Text('Все монеты, юниты и достижения будут сброшены.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Отмена')),TextButton(onPressed:(){s.updatePlayer((p){final fresh=Player();p.name=fresh.name;p.level=fresh.level;p.xp=fresh.xp;p.maxXp=fresh.maxXp;p.coins=fresh.coins;p.crystals=fresh.crystals;p.maxHp=fresh.maxHp;p.currentHp=fresh.currentHp;p.energy=fresh.energy;p.maxEnergy=fresh.maxEnergy;p.inventory=fresh.inventory;p.unlockedCharacters=fresh.unlockedCharacters;p.activeHeroId=fresh.activeHeroId;p.specialUnitCounts=fresh.specialUnitCounts;p.campaignLevelUnlocked=1;p.highestWave=0;p.seasonXp=0;p.seasonLevel=1;p.claimedQuests=[];p.clickDamageLevel=0;p.healthLevel=0;p.unitSpeedLevel=0;p.energyLevel=0;});Navigator.pop(ctx);},child:const Text('Сбросить'))]))),
    ]);
  }

  Widget _leaderboard(BuildContext context, ProgressService s) {
    final p=s.player;
    final rows=[['${p.name} (Вы)',p.highestWave*100+p.level*25+p.seasonLevel*10],['Пилот Nova',820],['Кибер-рыцарь',650],['VoidRunner',490],['PixelFox',320]];
    rows.sort((a,b)=>(b[1] as int).compareTo(a[1] as int));
    return ListView(padding:const EdgeInsets.all(14),children:[
      const Text('ЛОКАЛЬНЫЙ РЕЙТИНГ',style:TextStyle(color:Colors.amber,fontSize:11)),
      const SizedBox(height:8),
      const Text('Демо-таблица: остальные пилоты — локальные соперники, не реальные онлайн-игроки.',style:TextStyle(fontSize:8,color:Colors.white54)),
      ...List.generate(rows.length,(i)=>Card(color:const Color(0xFF202447),child:ListTile(leading:CircleAvatar(backgroundColor:i==0?Colors.amber:Colors.blueGrey,child:Text('${i+1}')),title:Text(rows[i][0] as String,style:const TextStyle(fontSize:10)),trailing:Text('${rows[i][1]} очков',style:const TextStyle(fontSize:9,color:Colors.cyan))))),
    ]);
  }

  Widget _wallet(int coins,int crystals,int energy)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.black26,borderRadius:BorderRadius.circular(14)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[Text('🪙 $coins'),Text('💎 $crystals'),Text('⚡ $energy')]));
  Widget _item(IconData icon,String name,String desc,String price,VoidCallback buy)=>Card(color:const Color(0xFF202447),child:ListTile(leading:Icon(icon,color:Colors.cyan),title:Text(name,style:const TextStyle(fontSize:10)),subtitle:Text(desc,style:const TextStyle(fontSize:8,color:Colors.white60)),trailing:TextButton(onPressed:buy,child:Text(price,style:const TextStyle(fontSize:8)))));
  Widget _upgrade(IconData icon,String name,String desc,int level,VoidCallback buy)=>Card(color:const Color(0xFF202447),child:ListTile(leading:Icon(icon,color:Colors.amber),title:Text(name,style:const TextStyle(fontSize:10)),subtitle:Text('$desc · Ур. $level',style:const TextStyle(fontSize:8)),trailing:TextButton(onPressed:buy,child:const Text('УЛУЧШИТЬ',style:TextStyle(fontSize:8)))));
  void _buy(ProgressService s,int cost,VoidCallback grant){if(s.player.coins<cost){_toast('Недостаточно монет');return;}s.updatePlayer((p)=>p.coins-=cost);grant();_toast('Покупка успешна');}
  void _buyCrystal(ProgressService s,int cost,VoidCallback grant){if(s.player.crystals<cost){_toast('Недостаточно кристаллов');return;}s.updatePlayer((p)=>p.crystals-=cost);grant();_toast('Покупка успешна');}
  void _upgradeBuy(ProgressService s,int type){final p=s.player;final level=[p.clickDamageLevel,p.healthLevel,p.unitSpeedLevel,p.energyLevel][type];final cost=100+level*80;if(p.coins<cost){_toast('Нужно $cost монет');return;}s.updatePlayer((p){p.coins-=cost;if(type==0)p.clickDamageLevel++;if(type==1){p.healthLevel++;p.maxHp+=20;p.currentHp+=20;}if(type==2)p.unitSpeedLevel++;if(type==3){p.energyLevel++;p.maxEnergy+=10;p.energy+=10;}});}
  void _claimQuest(ProgressService s,String id,bool season){if(s.player.claimedQuests.contains(id)){_toast('Уже получено');return;}s.updatePlayer((p){p.claimedQuests.add(id);if(id=='daily_tap'||id=='daily_wave')p.coins+=100;if(id=='daily_deploy')p.crystals+=5;if(id=='season_kills')p.crystals+=20;});_toast('Награда получена');}
  void _toast(String message){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message,style:const TextStyle(fontSize:10))));}
}
