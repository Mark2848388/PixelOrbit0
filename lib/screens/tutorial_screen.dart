import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  final List<_TutPage> _pages = const [
    _TutPage(
      title: 'Добро пожаловать!',
      body:
          'Ты — главный робот, защищающий орбиту Земли.\n\nВраги появляются с краёв круга и идут к тебе. Не дай им добраться!',
      icon: Icons.smart_toy,
      color: Color(0xFF4FC3F7),
    ),
    _TutPage(
      title: 'Тапай по врагам',
      body:
          'Чтобы наносить урон — тапай прямо по врагам!\n\nЧем быстрее тапаешь, тем быстрее они умирают. За убийства получаешь монеты и опыт.',
      icon: Icons.touch_app,
      color: Color(0xFFFF5722),
    ),
    _TutPage(
      title: 'Ставь юнитов',
      body:
          'В инвентаре есть:\n• Турелька — быстрая стрельба\n• Огневик — урон по площади\n• Щит — защита\n• Робот, Ползун, Усиление\n\nВыбери юнит → тапни на арену, чтобы поставить.',
      icon: Icons.construction,
      color: Color(0xFF9C27B0),
    ),
    _TutPage(
      title: 'Кампания и Сезон',
      body:
          'В Кампании — сюжетные уровни с боссами.\n\nСезонный пропуск длится до 1 декабря 2026. Получай особых персонажей и награды!',
      icon: Icons.star,
      color: Color(0xFFFFC107),
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.read<ProgressService>().completeTutorial();
      Navigator.pushReplacementNamed(context, '/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height:  100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.color.withOpacity(0.2),
                              border: Border.all(color: p.color, width: 3),
                            ),
                            child: Icon(p.icon, size: 52, color: p.color),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            p.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? Colors.cyan : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B68EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _page == _pages.length - 1 ? 'Начать игру!' : 'Далее',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutPage {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  const _TutPage({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });
}