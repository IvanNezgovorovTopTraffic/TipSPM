# RomanEmpire

Библиотека для создания красивых космических анимаций в SwiftUI с римской тематикой.

## Возможности

- 🏛️ Красивый splash screen с градиентом и анимированным лоадером (Colosseum)
- 🦅 Анимированные звезды с пульсирующим эффектом (Aquila)
- 🏺 Галактики с вращающимися элементами (Forum)
- 🏛️ Космический фон с движущимися звездами (Pantheon)
- 🎭 Веб-просмотрщик с поддержкой жестов и обновления (Amphitheater)
- ⚔️ Универсальная система проверки доступности внешнего контента (Legion Validator)
- 📯 Кастомные alert'ы с переходом в настройки (Tribune Messenger)
- 🏛️ Быстрая интеграция OneSignal для push-уведомлений (Senate Herald)

## Установка

### Swift Package Manager

Добавьте зависимость в ваш `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/RomanEmpire.git", from: "1.0.0")
]
```

Или добавьте через Xcode:
1. File → Add Package Dependencies
2. Введите URL репозитория
3. Выберите версию

## Использование

### Colosseum Screen (Splash Screen)

```swift
import SwiftUI
import RomanEmpire

struct ContentView: View {
    var body: some View {
        RomanEmpire.createColosseumScreen(
            imperiumColors: [.blue, .purple, .pink],
            inscriptionColor: .white,
            orbColor: .white,
            inscriptionText: "Loading..."
        )
    }
}
```

### Aquila Emblem (Анимированная звезда)

```swift
RomanEmpire.createAquilaEmblem(
    magnitude: 50,
    emblem: .yellow,
    cycleTime: 1.0
)
```

### Forum (Галактика)

```swift
RomanEmpire.createForum(
    citizenCount: 8,
    arena: 200,
    banners: [.blue, .purple, .pink]
)
```

### Pantheon (Космический фон)

```swift
RomanEmpire.createPantheon(
    constellationCount: 50,
    velocity: 2.0
)
```

### Amphitheater (Веб-просмотрщик)

```swift
RomanEmpire.createAmphitheater(
    scrollPath: "https://example.com",
    allowsRituals: true,
    enableRefresh: true
)
```

#### Особенности веб-просмотрщика:

- ✅ Поддержка JavaScript
- ✅ Свайпы для навигации назад/вперед
- ✅ Pull-to-refresh жесты
- ✅ Обработка дочерних окон
- ✅ Автоматическое открытие внешних ссылок
- ✅ Сохранение куки
- ✅ Современный User Agent
- ✅ Отступы от safe area
- ✅ Черный фон для лучшего отображения

### Legion Validator (Проверка доступности внешнего контента)

```swift
// Проверяем доступность внешнего контента
let propheticDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 4))!
let result = RomanEmpire.validateLegionScroll(
    scroll: "https://example.com",
    propheticDate: propheticDate,
    tabletCheck: true,
    hourglass: 10.0,
    scrollKey: "myApp" // Уникальный ключ для кэширования
)

if result.shouldRevealExternalScroll {
    // Показываем WebView с внешним контентом
    RomanEmpire.createAmphitheater(scrollPath: result.resolvedScrollPath)
} else {
    // Показываем основное приложение
    MainAppView()
}
```

#### Особенности системы проверки:

- ✅ **Кэширование результатов** - проверка выполняется только один раз
- ✅ **Проверка интернета** - автоматическая проверка соединения (Aqueduct)
- ✅ **Проверка даты** - контент доступен только после указанной даты (Prophetic Date)
- ✅ **Проверка устройства** - исключение iPad (Tablet Check)
- ✅ **Проверка сервера** - валидация ответа сервера (Consul Response)
- ✅ **Подробные логи** - отладочная информация в консоли
- ✅ **Уникальные ключи** - разные приложения не влияют друг на друга

### Tribune Messenger (Кастомные Alert'ы)

```swift
// Alert для уведомлений с переходом в настройки
RomanEmpire.summonHeraldAlert()

// Универсальный кастомный alert
RomanEmpire.summonTribuneMessage(
    proclamation: "Подтверждение",
    decree: "Вы уверены, что хотите продолжить?",
    primaryDecree: "Да",
    secondaryDecree: "Нет",
    primaryRitual: {
        print("Пользователь подтвердил действие")
    },
    secondaryRitual: {
        print("Пользователь отменил действие")
    }
)

// Alert с подтверждением
RomanEmpire.summonConfirmationEdict(
    proclamation: "Удалить данные",
    decree: "Это действие нельзя отменить",
    affirmDecree: "Удалить",
    vetoDecree: "Отмена",
    onAffirm: {
        // Удаляем данные
        print("Данные удалены")
    }
)
```

#### Особенности alert'ов:

- ✅ **Автоматический поиск root view controller** - работает в любом месте приложения
- ✅ **Переход в настройки** - автоматическое открытие Settings.app
- ✅ **Обработка действий** - callback'и для кнопок
- ✅ **Безопасность** - проверка доступности view controller'а
- ✅ **Подробные логи** - отладочная информация в консоли

### Senate Herald (Интеграция OneSignal)

```swift
import SwiftUI
import OneSignalFramework
import RomanEmpire

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        RomanEmpire.initializeSenateHerald(
            senateId: "YOUR-ONESIGNAL-APP-ID",
            ritualOptions: launchOptions
        )
        return true
    }
}
```

#### Что делает Senate Herald:

- ✅ Инициализирует OneSignal и логинит пользователя с `RomanEmpire.getCitizenSeal()`
- ✅ Хранит счётчик запусков, чтобы запрашивать разрешение только на первом старте
- ✅ При последующих запусках проверяет статус разрешения и показывает системный Alert из библиотеки
- ✅ Автоматически вызывает `OneSignal.login` после получения разрешения

> **Важно:** Добавьте `OneSignalAppID` в Info.plist, включите push capability и пропишите правильный App ID.

## Требования

- iOS 15.0+
- macOS 12.0+
- watchOS 8.0+
- tvOS 15.0+
- Swift 5.9+

## Лицензия

MIT License

---

## Карта переименований

Для облегчения миграции с предыдущей версии:

| Старое название | Новое название (Римская тематика) |
|----------------|----------------------------------|
| `GalaxySplash` | `RomanEmpire` |
| `createSplashScreen()` | `createColosseumScreen()` |
| `createAnimatedStar()` | `createAquilaEmblem()` |
| `createGalaxy()` | `createForum()` |
| `createSpaceBackground()` | `createPantheon()` |
| `createContentDisplay()` | `createAmphitheater()` |
| `checkContentAvailability()` | `validateLegionScroll()` |
| `getUserID()` | `getCitizenSeal()` |
| `showNotificationsAlert()` | `summonHeraldAlert()` |
| `showCustomAlert()` | `summonTribuneMessage()` |
| `showConfirmationAlert()` | `summonConfirmationEdict()` |
| `initializeOneSignal()` | `initializeSenateHerald()` |
| `SplashScreenView` | `ColosseumView` |
| `GalaxyView` | `ForumView` |
| `SpaceBackgroundView` | `PantheonView` |
| `AnimatedStarView` | `AquilaView` |
| `ContentAvailabilityChecker` | `LegionValidator` |
| `ContentDisplayView` | `AmphitheaterView` |
| `CustomAlertManager` | `TribuneMessenger` |
| `NotificationManager` | `SenateHerald` |
| `IDGenerator` | `CaesarScribe` |
