import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final seasonEnd = DateTime(2026, 12, 1);
bool get seasonActive => DateTime.now().isBefore(seasonEnd);

class P {
  static late SharedPreferences p;
  static String get name => p.getString('name') ?? 'Имя';
  static set name(String v) => p.setString('name', v);
  static int get coins => p.getInt('coins') ?? 100;
  static set coins(int v) => p.setInt('coins', v);
  static int get gems => p.getInt('gems') ?? 600;
  static set gems(int v) => p.setInt('gems', v);
  static int get xp => p.getInt('xp') ?? 0;
  static set xp(int v) => p.setInt('xp', v);
  static int get camp => p.getInt('camp') ?? 1;
  static set camp(int v) => p.setInt('camp', v);
  static bool get premium => p.getBool('prem') ?? false;
  static set premium(bool v) => p.setBool('prem', v);
  static String get hero => p.getString('hero') ?? 'bot';
  static set hero(String v) => p.setString('hero', v);
  static List<String> get claimed => p.getStringList('claimed') ?? [];
  static set claimed(List<String> v) => p.setStringList('claimed', v);
}

int get seasonLevel => min(30, P.xp ~/ 100);

class Hero {
  final String id, name, asset, desc;
  final int lvl;
  final bool prem;
  const Hero(this.id, this.name, this.asset, this.desc, this.lvl, this.prem);
}

const heroes = [
  Hero('bot', 'Бот A1-06', 'assets/icon.png', 'Базовый герой', 0, false),
  Hero('nova', 'Nova Guardian', 'assets/nova_guardian.png', 'Щит: HP базы x2, лечит базу', 10, false),
  Hero('void', 'Void Mage', 'assets/void_mage.png', 'Урон тапа x3', 5, true),
  Hero('overlord', 'Pixel Overlord', 'assets/pixel_overlord.png', 'Юниты +50% урона', 15, true),
];
bool unlocked(Hero h) => h.lvl == 0 || (seasonLevel >= h.lvl && (!h.prem || P.premium));
Hero get curHero => heroes.firstWhere((h) => h.id == P.hero, orElse: () => heroes[0]);

class Sfx {
  static final ps = List.generate(4, (_) => AudioPlayer());
  static int i = 0;
  static void play(String n) {
    try {
      final p = ps[i++ % 4];
      p.stop();
      p.play(AssetSource('sfx/$n.wav'));
    } catch (_) {}
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  P.p = await SharedPreferences.getInstance();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Menu()));
}

const bg = BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2B2160), Color(0xFF6A4FB0), Color(0xFF3E7A3A)]));

Widget btn(String t, VoidCallback? f, {Color c = const Color(0xFF3A2D78)}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SizedBox(
        width: 260,
        height: 52,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: c, side: const BorderSide(color: Color(0xFFE8B83C), width: 2), shape: const RoundedRectangleBorder()),
            onPressed: f,
            child: Text(t, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)))));

class HeroView extends StatefulWidget {
  final Hero h;
  final double height, pulse;
  const HeroView(this.h, this.height, {this.pulse = 0, super.key});
  @override
  State<HeroView> createState() => _HeroViewState();
}

class _HeroViewState extends State<HeroView> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        final t = c.value * 2 * pi;
        return Transform.translate(
            offset: Offset(0, sin(t) * 5),
            child: Transform.scale(
                scale: 1 + sin(t) * .015 + widget.pulse * .1,
                child: Container(
                    decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(.15 + .15 * (1 + sin(t)) / 2), blurRadius: 30)]),
                    child: Image.asset(widget.h.asset, height: widget.height, filterQuality: FilterQuality.none))));
      });
}

class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w)).then((_) => setState(() {}));
  void soon(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$t — скоро')));
  void rename() {
    final c = TextEditingController(text: P.name);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(title: const Text('Имя'), content: TextField(controller: c, maxLength: 14), actions: [
              TextButton(
                  onPressed: () {
                    if (c.text.trim().isNotEmpty) P.name = c.text.trim();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('OK'))
            ]));
  }
  void shop() => showDialog(
      context: context,
      builder: (_) => AlertDialog(title: const Text('Магазин'), content: Text(P.premium ? 'Премиум пропуск уже куплен' : 'Премиум сезонного пропуска: 💎500'), actions: [
            if (!P.premium && P.gems >= 500)
              TextButton(
                  onPressed: () {
                    P.gems -= 500;
                    P.premium = true;
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Купить'))
          ]));
  Widget tile(String ic, String lb, VoidCallback f) => GestureDetector(
      onTap: f,
      child: Column(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFF1E2550), border: Border.all(color: const Color(0xFFE8B83C), width: 2), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(ic, style: const TextStyle(fontSize: 32)))),
        const SizedBox(height: 4),
        Text(lb, style: const TextStyle(color: Color(0xFF2B2160), fontWeight: FontWeight.bold, fontSize: 13)),
      ]));
  Widget orb(String ic, String lb, Color c, VoidCallback f) => GestureDetector(
      onTap: f,
      child: Column(children: [
        Container(width: 96, height: 96, decoration: BoxDecoration(shape: BoxShape.circle, color: c, border: Border.all(color: const Color(0xFFE8B83C), width: 3)), child: Center(child: Text(ic, style: const TextStyle(fontSize: 46)))),
        Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1E2550), border: Border.all(color: const Color(0xFFE8B83C), width: 2)), child: Text(lb, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
      ]));
  Widget panel(Widget c) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1E2550), border: Border.all(color: const Color(0xFFE8B83C), width: 2), borderRadius: BorderRadius.circular(8)), child: c);
  @override
  Widget build(BuildContext context) {
    final left = seasonEnd.difference(DateTime.now());
    final now = TimeOfDay.now();
    final tm = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    const w = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8E86D8), Color(0xFFC8B8E8), Color(0xFF8CC860)])),
            child: SafeArea(
                child: Stack(children: [
              Positioned(left: 0, right: 0, bottom: 0, height: 230, child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xFF4C9A3A)])))),
              Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  child: panel(Row(children: [
                    GestureDetector(onTap: rename, child: Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE8B83C), width: 2)), child: const Center(child: Text('🤖', style: TextStyle(fontSize: 30))))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(P.name, style: w),
                      Row(children: [
                        Text('Хр ${P.xp ~/ 100}  ', style: const TextStyle(color: Color(0xFFE8B83C), fontWeight: FontWeight.bold)),
                        Expanded(child: LinearProgressIndicator(value: (P.xp % 100) / 100, color: Colors.green, backgroundColor: Colors.black45, minHeight: 10))
                      ])
                    ])),
                    const SizedBox(width: 8),
                    Text('🪙 ${P.coins}\n💎 ${P.gems}', style: w),
                  ]))),
              Positioned(top: 84, left: 0, right: 0, child: Center(child: panel(Text('☀ $tm', style: w)))),
              Positioned(left: 10, top: 130, child: tile('🏪', 'магазин', shop)),
              Positioned(left: 10, top: 230, child: tile('🏠', 'настройки', rename)),
              Positioned(right: 10, top: 130, child: tile('📜', 'КВЕСТЫ', () => soon('Квесты'))),
              Positioned(right: 10, top: 230, child: tile('🏆', 'рейтинг', () => soon('Рейтинг'))),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 120,
                  child: Column(children: [
                    orb('🏰', 'МИРЫ', const Color(0xFF2E7BD6), () => go(const Campaign())),
                    const SizedBox(height: 8),
                    orb('⚔', 'РЕЖИМЫ', const Color(0xFF2E8B3A), () => go(const Game(11))),
                    const SizedBox(height: 8),
                    orb('🌌', 'ИСПЫТАНИЯ', const Color(0xFF5B2E9A), () => soon('Испытания')),
                  ])),
              Positioned(left: 18, bottom: 150, child: Column(children: [
                Text('скин: ${curHero.name}', style: const TextStyle(color: Color(0xFF2B2160), fontWeight: FontWeight.bold)),
                HeroView(curHero, 130),
              ])),
              Positioned(
                  right: 10,
                  bottom: 100,
                  child: GestureDetector(
                      onTap: () => go(const Pass()),
                      child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF3A2468), border: Border.all(color: const Color(0xFF9A6AE8), width: 2), borderRadius: BorderRadius.circular(8)),
                          child: Column(children: [
                            Text(seasonActive ? '⏱ ${left.inDays}д ${left.inHours % 24}ч' : 'завершён', style: w),
                            const Text('🪐🏯', style: TextStyle(fontSize: 40)),
                            const Text('Ивент\nСезон 1', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ])))),
              Positioned(
                  left: 8,
                  bottom: 12,
                  child: panel(Column(children: [
                    const Text('ДРУЗЬЯ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Row(children: [
                      for (final e in ['🧑', '🧒']) Container(margin: const EdgeInsets.all(4), width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24, border: Border.all(color: const Color(0xFFE8B83C), width: 2)), child: Center(child: Text(e, style: const TextStyle(fontSize: 26)))),
                      GestureDetector(onTap: () => soon('Друзья'), child: Container(margin: const EdgeInsets.all(4), width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white12), child: const Center(child: Text('+', style: TextStyle(color: Colors.white, fontSize: 28))))),
                    ])
                  ]))),
              Positioned(right: 10, bottom: 12, child: ElevatedButton(onPressed: () => go(const Heroes()), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2550), shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0xFFE8B83C), width: 2))), child: const Text('🦸 ГЕРОИ', style: TextStyle(color: Colors.white)))),
            ]))));
  }
}

Widget page(BuildContext c, String title, Widget body) => Scaffold(
    appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF2B2160), foregroundColor: Colors.white),
    body: Container(decoration: bg, width: double.infinity, child: body));

class Campaign extends StatefulWidget {
  const Campaign({super.key});
  @override
  State<Campaign> createState() => _CampaignState();
}

class _CampaignState extends State<Campaign> {
  @override
  Widget build(BuildContext context) => page(
      context,
      'Кампания',
      GridView.count(crossAxisCount: 2, padding: const EdgeInsets.all(16), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6, children: [
        for (var l = 1; l <= 10; l++)
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: l <= P.camp ? const Color(0xFF3A2D78) : Colors.black54, shape: const RoundedRectangleBorder()),
              onPressed: l <= P.camp ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => Game(l))).then((_) => setState(() {})) : null,
              child: Text(l == 10 ? 'Уровень 10\n👑 БОСС' : 'Уровень $l', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18))),
      ]));
}

class Heroes extends StatefulWidget {
  const Heroes({super.key});
  @override
  State<Heroes> createState() => _HeroesState();
}

class _HeroesState extends State<Heroes> {
  @override
  Widget build(BuildContext context) => page(
      context,
      'Герои',
      ListView(children: [
        for (final h in heroes)
          Card(
              color: Colors.black38,
              child: ListTile(
                  leading: Image.asset(h.asset, width: 48, filterQuality: FilterQuality.none),
                  title: Text(h.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(unlocked(h) ? h.desc : '${h.desc}\n🔒 Пропуск ур.${h.lvl}${h.prem ? " (премиум)" : ""}', style: const TextStyle(color: Colors.white70)),
                  trailing: P.hero == h.id ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: unlocked(h) ? () => setState(() => P.hero = h.id) : null))
      ]));
}

class Pass extends StatefulWidget {
  const Pass({super.key});
  @override
  State<Pass> createState() => _PassState();
}

class _PassState extends State<Pass> {
  void claim(String k, int coins) {
    final c = P.claimed..add(k);
    P.claimed = c;
    P.coins += coins;
    Sfx.play('buy');
    setState(() {});
  }
  @override
  Widget build(BuildContext context) => page(
      context,
      'Сезон 1 • до 1 декабря',
      Column(children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Ур. $seasonLevel/30  (${P.xp % 100}/100 XP)', style: const TextStyle(color: Colors.white)),
              P.premium
                  ? const Text('⭐ ПРЕМИУМ', style: TextStyle(color: Color(0xFFE8B83C)))
                  : ElevatedButton(
                      onPressed: P.gems >= 500
                          ? () => setState(() {
                                P.gems -= 500;
                                P.premium = true;
                              })
                          : null,
                      child: const Text('Премиум 💎500'))
            ])),
        Expanded(
            child: ListView.builder(
                itemCount: 30,
                itemBuilder: (_, i) {
                  final l = i + 1;
                  final hero = heroes.where((h) => h.lvl == l).toList();
                  final fk = 'f$l', pk = 'p$l';
                  final reached = seasonLevel >= l;
                  return Card(
                      color: Colors.black38,
                      child: ListTile(
                          leading: Text('$l', style: const TextStyle(color: Colors.white, fontSize: 22)),
                          title: Text('Бесплатно: ${hero.isNotEmpty && !hero[0].prem ? "🦸 ${hero[0].name}" : "🪙 50"}', style: const TextStyle(color: Colors.white)),
                          subtitle: Text('Премиум: ${hero.isNotEmpty && hero[0].prem ? "🦸 ${hero[0].name}" : "🪙 120"}', style: const TextStyle(color: Color(0xFFE8B83C))),
                          trailing: Column(mainAxisSize: MainAxisSize.min, children: [
                            if (reached && !P.claimed.contains(fk)) GestureDetector(onTap: () => claim(fk, 50), child: const Text('Взять', style: TextStyle(color: Colors.greenAccent))),
                            if (reached && P.premium && !P.claimed.contains(pk)) GestureDetector(onTap: () => claim(pk, 120), child: const Text('Взять⭐', style: TextStyle(color: Colors.amber))),
                          ])));
                }))
      ]));
}

class En {
  double x, y, hp, max, spd, slow = 1;
  bool boss;
  String e;
  En(this.x, this.y, this.hp, this.spd, this.e, this.boss) : max = hp;
}

class Un {
  int t, lv = 1;
  double cd = 0, x, y;
  Un(this.t, this.x, this.y);
}

class Fl {
  double x, y, life = .7;
  String s;
  Fl(this.x, this.y, this.s);
}

class Bm {
  double x1, y1, x2, y2, life = .12;
  Color c;
  Bm(this.x1, this.y1, this.x2, this.y2, this.c);
}

class BeamPainter extends CustomPainter {
  final List<Bm> b;
  BeamPainter(this.b);
  @override
  void paint(Canvas cv, Size s) {
    for (final m in b) {
      cv.drawLine(Offset(m.x1 * s.width, m.y1 * s.height), Offset(m.x2 * s.width, m.y2 * s.height), Paint()..color = m.c..strokeWidth = 3);
    }
  }
  @override
  bool shouldRepaint(_) => true;
}

const uNames = ['Турель', 'Огневик', 'Щит', 'Робот'];
const uEmo = ['🔫', '🔥', '🛡️', '🤖'];
const uCost = [30, 60, 50, 70];

class Game extends StatefulWidget {
  final int level;
  const Game(this.level, {super.key});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  late final Ticker tk;
  final rnd = Random();
  Duration last = Duration.zero;
  Size sz = const Size(400, 800);
  final en = <En>[];
  final units = <Un>[];
  final fl = <Fl>[];
  final bm = <Bm>[];
  int gold = 60, spawned = 0, total = 0, kills = 0, sel = -1, status = 0;
  double base = 100, baseMax = 100, spawnT = 1, pulse = 0, healT = 0;
  double tapMul = 1, unitMul = 1;

  @override
  void initState() {
    super.initState();
    total = widget.level >= 11 ? 999999 : 10 + widget.level * 5;
    final h = P.hero;
    if (h == 'void') tapMul = 3;
    if (h == 'overlord') unitMul = 1.5;
    if (h == 'nova') baseMax = 200;
    base = baseMax;
    tk = createTicker(tick)..start();
  }

  @override
  void dispose() {
    tk.dispose();
    super.dispose();
  }

  double dist(double ax, double ay, double bx, double by) => sqrt(pow((ax - bx) * sz.width, 2) + pow((ay - by) * sz.height, 2)) / sz.width;

  void hit(En e, double d) {
    e.hp -= d;
    fl.add(Fl(e.x, e.y - .04, d.toStringAsFixed(0)));
  }

  En? nearest(double x, double y, double r) {
    En? b;
    var bd = r;
    for (final e in en) {
      final d = dist(x, y, e.x, e.y);
      if (d < bd) {
        bd = d;
        b = e;
      }
    }
    return b;
  }

  void tick(Duration el) {
    var dt = (el - last).inMicroseconds / 1e6;
    last = el;
    if (dt > .05) dt = .05;
    if (status != 0) return;
    pulse = max(0, pulse - dt * 4);
    spawnT -= dt;
    if (spawned < total && spawnT <= 0) {
      final boss = spawned == total - 1 && widget.level % 5 == 0 || (spawned == total - 1 && widget.level == 10);
      final hp = (12 + widget.level * 7 + spawned * 1.2) * (boss ? 10 : 1);
      en.add(En(.1 + rnd.nextDouble() * .8, 0, hp, (.05 + widget.level * .004) * (boss ? .6 : 1), boss ? '🐲' : ['👾', '👹', '🐙', '👻'][rnd.nextInt(4)], boss));
      spawned++;
      spawnT = max(.45, 1.4 - widget.level * .07);
    }
    for (final e in en) {
      e.slow = 1;
    }
    for (final u in units) {
      u.cd -= dt;
      final ux = u.x, uy = u.y;
      final m = (1 + .5 * (u.lv - 1)) * unitMul;
      if (u.t == 2) {
        for (final e in en) {
          if (dist(ux, uy, e.x, e.y) < .3) e.slow = .5;
        }
        if (u.cd <= 0) {
          u.cd = 2;
          base = min(baseMax, base + 3.0 * u.lv);
        }
        continue;
      }
      if (u.cd > 0) continue;
      final r = [1.0, .85, 0, .4][u.t];
      final tg = nearest(ux, uy, r);
      if (tg == null) continue;
      if (u.t == 0) {
        u.cd = .6;
        hit(tg, 6 * m);
        bm.add(Bm(ux, uy, tg.x, tg.y, Colors.yellowAccent));
        Sfx.play('shoot');
      } else if (u.t == 1) {
        u.cd = 1.6;
        bm.add(Bm(ux, uy, tg.x, tg.y, Colors.deepOrange));
        for (final e in en.toList()) {
          if (dist(tg.x, tg.y, e.x, e.y) < .22) hit(e, 12 * m);
        }
        Sfx.play('boom');
      } else {
        u.cd = .35;
        hit(tg, 5 * m);
        bm.add(Bm(ux, uy, tg.x, tg.y, Colors.cyanAccent));
      }
    }
    for (final e in en) {
      e.y += e.spd * dt * e.slow;
    }
    for (final e in en.toList()) {
      if (e.hp <= 0) {
        en.remove(e);
        kills++;
        gold += e.boss ? 40 : 6;
        Sfx.play('hit');
      } else if (e.y >= .8) {
        en.remove(e);
        base -= e.boss ? 40 : 8;
        Sfx.play('boom');
      }
    }
    for (final f in fl) {
      f.life -= dt;
      f.y -= dt * .05;
    }
    fl.removeWhere((f) => f.life <= 0);
    for (final b in bm) {
      b.life -= dt;
    }
    bm.removeWhere((b) => b.life <= 0);
    if (P.hero == 'nova') {
      healT += dt;
      if (healT > 3) {
        healT = 0;
        base = min(baseMax, base + 5);
      }
    }
    if (base <= 0) {
      status = 2;
      Sfx.play('lose');
    } else if (spawned >= total && en.isEmpty) {
      status = 1;
      Sfx.play('win');
      P.coins += 40 + widget.level * 15;
      if (seasonActive) P.xp += 40 + kills ~/ 3;
      if (widget.level == P.camp && P.camp < 10) P.camp = P.camp + 1;
    }
    setState(() {});
  }

  void tapAt(TapDownDetails d) {
    if (status != 0) return;
    final x = d.localPosition.dx / sz.width, y = d.localPosition.dy / sz.height;
    if (sel >= 0 && y > .5 && y < .78) {
      Un? near;
      for (final u in units) {
        if (dist(x, y, u.x, u.y) < .09) near = u;
      }
      if (near != null) {
        if (near.lv < 5 && gold >= 40 * near.lv) {
          gold -= 40 * near.lv;
          near.lv++;
          Sfx.play('buy');
        }
      } else if (units.length < 10 && gold >= uCost[sel]) {
        gold -= uCost[sel];
        units.add(Un(sel, x, y));
        Sfx.play('buy');
      }
      return;
    }
    pulse = 1;
    Sfx.play('tap');
    final e = nearest(x, y, .13);
    if (e != null) hit(e, 5 * tapMul);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: LayoutBuilder(builder: (c, box) {
        sz = Size(box.maxWidth, box.maxHeight);
        final w = sz.width, h = sz.height;
        return Container(
            decoration: bg,
            child: Stack(children: [
              Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTapDown: tapAt)),
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: BeamPainter(bm)))),
              Positioned(left: 0, right: 0, top: .8 * h, child: Container(height: 3, color: Colors.redAccent)),
              for (final e in en)
                Positioned(
                    left: e.x * w - 24,
                    top: e.y * h - 24 + sin(e.y * 40) * 4,
                    child: IgnorePointer(
                        child: Column(children: [
                      Text(e.e, style: TextStyle(fontSize: e.boss ? 52 : 34)),
                      SizedBox(width: 40, child: LinearProgressIndicator(value: (e.hp / e.max).clamp(0, 1), color: Colors.red, backgroundColor: Colors.black54, minHeight: 4)),
                    ]))),
              for (final f in fl) Positioned(left: f.x * w, top: f.y * h, child: IgnorePointer(child: Text(f.s, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              if (sel >= 0)
                Positioned(left: 0, right: 0, top: .5 * h, height: .28 * h, child: IgnorePointer(child: Container(decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: Colors.white38)), child: const Align(alignment: Alignment.topCenter, child: Text('Тап по базе — поставить, по юниту — улучшить', style: TextStyle(color: Colors.white70, fontSize: 12)))))),
              for (final u in units)
                Positioned(
                    left: u.x * w - 24,
                    top: u.y * h - 24 + sin(last.inMilliseconds / 250 + u.x * 9) * 3,
                    child: IgnorePointer(child: Text('${uEmo[u.t]}${u.lv}', style: const TextStyle(fontSize: 30)))),
              Positioned(bottom: 84, left: 0, right: 0, child: IgnorePointer(child: Center(child: HeroView(curHero, h * .16, pulse: pulse)))),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                      child: Container(
                          color: Colors.black45,
                          padding: const EdgeInsets.all(8),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('❤ ${base.ceil()}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                            Text('🪙 $gold', style: const TextStyle(color: Colors.amber, fontSize: 18)),
                            Text('Волна ${min(spawned, total)}/$total', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ])))),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      height: 78,
                      color: Colors.black54,
                      child: Row(children: [
                        for (var t = 0; t < 4; t++)
                          Expanded(
                              child: GestureDetector(
                                  onTap: () => setState(() => sel = sel == t ? -1 : t),
                                  child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(border: Border.all(color: sel == t ? Colors.amber : Colors.white24, width: 2)),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(uEmo[t], style: const TextStyle(fontSize: 24)), Text('${uNames[t]} ${uCost[t]}', style: const TextStyle(color: Colors.white, fontSize: 11))]))))
                      ]))),
              if (status != 0)
                Positioned.fill(
                    child: Container(
                        color: Colors.black87,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(status == 1 ? '🏆 ПОБЕДА!' : '💀 ПОРАЖЕНИЕ', style: const TextStyle(color: Colors.white, fontSize: 32)),
                          if (status == 1) Text('+${40 + widget.level * 15} 🪙   +${40 + kills ~/ 3} XP сезона', style: const TextStyle(color: Colors.amber, fontSize: 18)),
                          const SizedBox(height: 20),
                          btn('В МЕНЮ', () => Navigator.pop(context)),
                        ]))),
            ]));
      }));
}
