# Pixel Orbit (Flutter)

Кликер / idle tower-defense в стиле старой версии Pixel Orbit.

## Особенности

- Тапай **по врагам**, чтобы наносить урон
- Размещай юнитов: **Турелька, Огневик, Щит, Робот, Ползун, Усиление**
- Полноценное **обучение** при первом запуске
- **Кампания** из 6 уровней с боссами
- **Сезонный пропуск** (Сезон 1 «Прибытие» — до **1 декабря 2026**)
- Особые персонажи сезона
- Автосохранение прогресса
- GitHub Actions → автоматическая сборка APK + AAB

## Скриншоты (референс)

Игра сделана по твоим двум скриншотам (меню + арена с инвентарём).

## Как запустить

```bash
flutter pub get
flutter run
```

## Сборка релиза

```bash
flutter build apk --release
flutter build appbundle --release
```

## GitHub Actions

При пуше в `main`/`master` автоматически:

1. Собирается release APK (split-per-abi)
2. Собирается App Bundle
3. Артефакты загружаются в Actions (хранятся 30 дней)

Просто создай репозиторий, запушь весь код — сборка пойдёт сама.

## Структура

```
lib/
  main.dart
  models/          # Player, Unit, Enemy, Season, Campaign
  services/        # GameService, ProgressService
  screens/         # Splash, Tutorial, Menu, Game, Campaign, Season
  widgets/
assets/
  icons/app_icon.png
```

## Сезон 1

- Название: **Прибытие**
- Окончание: **1 декабря 2026**
- Особые персонажи: Кибер-Рыцарь, Маг Пустоты, Страж Новы, Пиксель-Оверлорд

Удачи в защите орбиты! 🚀
```