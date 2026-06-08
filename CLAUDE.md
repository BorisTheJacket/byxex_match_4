# Byxex Match — Cyber Club App

## Проект
Flutter-додаток для кіберклубу Byxex Match (бренд Betmatch).
- Flutter 3.32.8 / Dart 3.8.1
- Шлях до Flutter: `/Users/hospodar/Extensions/flutter/bin/flutter`

## Що робимо
Відтворюємо дизайн з Figma **екран за екраном**, звіряючи кожен скріншот з реальним пристроєм.
Стратегія: користувач надсилає Figma-скріншот + assets → ми пишемо код → користувач надсилає скріншот з пристрою → правимо до збігу.

## Архітектура
- **Навігація**: `go_router`, плоскі маршрути (без `ShellRoute`, без bottom nav)
- **Анімації**: `flutter_animate`
- **Шрифт**: `BlackHanSans` (файл: `assets/fonts/BlackHanSans-Regular.ttf`) — використовується СКРІЗЬ
- **Зберігання**: `shared_preferences` (nickname, avatar index, onboarded flag)
- **QR**: `qr_flutter` (генерація), `mobile_scanner` (сканування)

## Кольори (`lib/core/theme/app_colors.dart`)
- background: `#0B18B5`
- surface: `#0E1FCC`
- card: `#1A2CD4`
- accentGreen: `#00D455`
- accentCyan: `#00D4FF`

## Ключові віджети (`lib/core/widgets/screen_header.dart`)
- `ByxexBackground` — синій градієнт + горизонтальні смуги
- `ByxexHeader(title)` — трапецієподібний банер з cyan slash з обох боків
- `ByxexButton(label, onTap)` — зелена кнопка, `borderRadius: 14`
- `ByxexTextField(label, controller, hint)` — темне поле вводу

## Assets (`assets/images/`)
### Фони (повноекранні, BoxFit.cover)
- `splash_bg.png` — фон сплеш-екрану (cyan смуги)
- `onboarding_bg.png` — фон онбордингу (з лого BYXEX MATCH вгорі зліва)
- `nickname_bg.png` — фон екрану нікнейму

### Логотипи
- `splash_icon.png` — зелений M-shield логотип
- `splash_text.png` — текст "BYXEX MATCH CYBER CLUB"

### Аватари
- `avatar_headset.png` — **спрайт з 5 аватарів** в один рядок
  - Кроп формула: `alignX = -1.0 + (2.0 * i / 4)`, `OverflowBox(maxWidth: size * 5)`

### Онбординг
- `onboarding_pc.png` — PC + шестерні (слайд 1), `widthFactor: 1.5`, `alignment: (-0.5, -0.55)`
- `onboarding_trophy.png` — золотий кубок (слайд 2), `widthFactor: 1.7`, `alignment: (0, -0.5)`
- `onboarding_events.png` — медальйон (слайд 3), `widthFactor: 1.0`, `alignment: (0, -0.5)`

## Екрани (всі реалізовані)
| Маршрут | Файл | Статус |
|---------|------|--------|
| `/` | splash_screen.dart | ✅ |
| `/onboarding` | onboarding_screen.dart | ✅ |
| `/nickname` | nickname_screen.dart | ✅ |
| `/home` | home_screen.dart | потребує перевірки |
| `/profile` | profile_screen.dart | ✅ |
| `/menu` | menu_screen.dart | ✅ |
| `/prices` | prices_screen.dart | ✅ |
| `/games` | games_screen.dart | ✅ |
| `/events` | events_screen.dart | ✅ |
| `/tasks` | tasks_screen.dart | ✅ |
| `/qr-code` | qr_code_screen.dart | ✅ |
| `/booking` | booking_form_screen.dart | ✅ |
| `/about` | about_screen.dart | ✅ |
| `/pc-control` | pc_control_screen.dart | потребує перевірки |

## Важливі правила
1. **Шрифт завжди BlackHanSans** — `TextStyle(fontFamily: 'BlackHanSans')`
2. **Кнопки** — `borderRadius: 14` (не pill-shape 30)
3. **Фони** — використовувати `Image.asset` + `BoxFit.cover` в `Stack`, НЕ `ByxexBackground` на нових екранах
4. **Порожній простір** — використовувати `Expanded` Column замість `ListView`/`GridView` де контент має заповнювати екран
5. **Аватар спрайт** — `OverflowBox` з формулою alignment, НЕ `BoxFit.cover` на весь спрайт
