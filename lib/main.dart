import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/game_service.dart';
import 'services/progress_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/season_pass_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/characters_screen.dart';
import 'screens/game_hub_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final progress = ProgressService();
  await progress.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => progress),
        ChangeNotifierProxyProvider<ProgressService, GameService>(
          create: (ctx) => GameService(ctx.read<ProgressService>()),
          update: (_, progress, previous) => previous ?? GameService(progress),
        ),
      ],
      child: const PixelOrbitApp(),
    ),
  );
}

class PixelOrbitApp extends StatelessWidget {
  const PixelOrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Orbit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        primaryColor: const Color(0xFF7B68EE),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B68EE),
          secondary: Color(0xFF00D2FF),
          surface: Color(0xFF16213E),
        ),
        textTheme: GoogleFonts.pressStart2pTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/tutorial': (context) => const TutorialScreen(),
        '/menu': (context) => const MainMenuScreen(),
        '/game': (context) => const GameScreen(),
        '/campaign': (context) => const CampaignScreen(),
        '/season': (context) => const SeasonPassScreen(),
        '/characters': (context) => const CharactersScreen(),
        '/hub': (context) => const GameHubScreen(),
      },
    );
  }
}