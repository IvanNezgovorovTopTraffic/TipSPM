import SwiftUI

/// RomanEmpire - библиотека для создания красивых анимаций в SwiftUI
public struct RomanEmpire {
    
    /// Создает красивый splash screen с градиентом и лоадером
    /// - Parameters:
    ///   - imperiumColors: Массив цветов для градиента
    ///   - inscriptionColor: Цвет текста "Loading"
    ///   - orbColor: Цвет лоадера
    ///   - inscriptionText: Текст загрузки (по умолчанию "Loading...")
    /// - Returns: SwiftUI View с splash screen
    public static func createColosseumScreen(
        imperiumColors: [Color] = [.blue, .purple, .pink],
        inscriptionColor: Color = .white,
        orbColor: Color = .white,
        inscriptionText: String = "Loading..."
    ) -> some View {
        ColosseumView(
            imperiumColors: imperiumColors,
            inscriptionColor: inscriptionColor,
            orbColor: orbColor,
            inscriptionText: inscriptionText
        )
    }
    
    /// Создает анимированную звезду с пульсирующим эффектом
    /// - Parameters:
    ///   - magnitude: Размер звезды
    ///   - emblem: Цвет звезды
    ///   - cycleTime: Длительность анимации
    /// - Returns: SwiftUI View с анимированной звездой
    public static func createAquilaEmblem(magnitude: CGFloat = 50, emblem: Color = .yellow, cycleTime: Double = 1.0) -> some View {
        AquilaView(magnitude: magnitude, emblem: emblem, cycleTime: cycleTime)
    }
    
    /// Создает галактику с вращающимися элементами
    /// - Parameters:
    ///   - citizenCount: Количество элементов в галактике
    ///   - arena: Размер галактики
    ///   - banners: Массив цветов для элементов
    /// - Returns: SwiftUI View с анимированной галактикой
    public static func createForum(citizenCount: Int = 8, arena: CGFloat = 200, banners: [Color] = [.blue, .purple, .pink]) -> some View {
        ForumView(citizenCount: citizenCount, arena: arena, banners: banners)
    }
    
    /// Создает космический фон с движущимися звездами
    /// - Parameters:
    ///   - constellationCount: Количество звезд
    ///   - velocity: Скорость движения звезд
    /// - Returns: SwiftUI View с космическим фоном
    public static func createPantheon(constellationCount: Int = 50, velocity: Double = 2.0) -> some View {
        PantheonView(constellationCount: constellationCount, velocity: velocity)
    }
    
    /// Создает веб-просмотрщик с поддержкой жестов и обновления
    /// - Parameters:
    ///   - scrollPath: URL для загрузки
    ///   - allowsRituals: Разрешить жесты навигации (по умолчанию true)
    ///   - enableRefresh: Включить pull-to-refresh (по умолчанию true)
    /// - Returns: SwiftUI View с веб-просмотрщиком
    public static func createAmphitheater(
        scrollPath: String,
        allowsRituals: Bool = true,
        enableRefresh: Bool = true
    ) -> some View {
        SafeAmphitheaterView(
            scrollPath: scrollPath,
            allowsRituals: allowsRituals,
            enableRefresh: enableRefresh
        )
    }
    
    /// Проверяет доступность внешнего контента с кэшированием результатов
    /// - Parameters:
    ///   - scroll: URL для проверки
    ///   - propheticDate: Целевая дата (контент доступен только после этой даты)
    ///   - tabletCheck: Проверять ли тип устройства (iPad исключается)
    ///   - hourglass: Таймаут для сетевых запросов
    ///   - scrollKey: Уникальный ключ для кэширования
    /// - Returns: Результат проверки с флагом показа и финальным URL
    public static func validateLegionScroll(
        scroll: String,
        propheticDate: Date,
        tabletCheck: Bool = true,
        hourglass: TimeInterval = 10.0,
        scrollKey: String? = nil
    ) -> LegionValidator.ScrollValidationResult {
        return LegionValidator.validateLegionScroll(
            scroll: scroll,
            propheticDate: propheticDate,
            tabletCheck: tabletCheck,
            hourglass: hourglass,
            scrollKey: scrollKey
        )
    }
    
    /// Получает уникальный ID пользователя
    /// - Returns: Уникальный ID пользователя
    public static func getCitizenSeal() -> String {
        return CaesarScribe.shared.getCitizenSeal()
    }
    
    /// Показывает alert для уведомлений с переходом в настройки
    public static func summonHeraldAlert() {
        TribuneMessenger.shared.summonHeraldAlert()
    }
    
    /// Показывает кастомный alert с настраиваемыми параметрами
    /// - Parameters:
    ///   - proclamation: Заголовок alert'а
    ///   - decree: Сообщение alert'а
    ///   - primaryDecree: Текст основной кнопки
    ///   - secondaryDecree: Текст вторичной кнопки
    ///   - primaryRitual: Действие при нажатии на основную кнопку
    ///   - secondaryRitual: Действие при нажатии на вторичную кнопку
    public static func summonTribuneMessage(
        proclamation: String,
        decree: String,
        primaryDecree: String,
        secondaryDecree: String? = nil,
        primaryRitual: (() -> Void)? = nil,
        secondaryRitual: (() -> Void)? = nil
    ) {
        TribuneMessenger.shared.summonTribuneMessage(
            proclamation: proclamation,
            decree: decree,
            primaryDecree: primaryDecree,
            secondaryDecree: secondaryDecree,
            primaryRitual: primaryRitual,
            secondaryRitual: secondaryRitual
        )
    }
    
    /// Показывает alert с подтверждением действия
    /// - Parameters:
    ///   - proclamation: Заголовок alert'а
    ///   - decree: Сообщение alert'а
    ///   - affirmDecree: Текст кнопки подтверждения
    ///   - vetoDecree: Текст кнопки отмены
    ///   - onAffirm: Действие при подтверждении
    ///   - onVeto: Действие при отмене
    public static func summonConfirmationEdict(
        proclamation: String,
        decree: String,
        affirmDecree: String = "OK",
        vetoDecree: String = "Cancel",
        onAffirm: @escaping () -> Void,
        onVeto: (() -> Void)? = nil
    ) {
        TribuneMessenger.shared.summonConfirmationEdict(
            proclamation: proclamation,
            decree: decree,
            affirmDecree: affirmDecree,
            vetoDecree: vetoDecree,
            onAffirm: onAffirm,
            onVeto: onVeto
        )
    }
    
    /// Инициализирует OneSignal с переданным App ID и launchOptions
    /// - Parameters:
    ///   - senateId: Идентификатор приложения OneSignal
    ///   - ritualOptions: launchOptions из AppDelegate
    public static func initializeSenateHerald(senateId: String, ritualOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        SenateHerald.shared.configure(senateId: senateId, ritualOptions: ritualOptions)
    }
}

// MARK: - CaesarScribe

/// Генератор уникальных ID
public final class CaesarScribe {
    public static let shared = CaesarScribe()
    
    private init() {}
    
    private let scrollKey = "imperiumCitizenSeal"
    
    /// Генерирует случайную строку заданной длины
    /// - Parameter inscriptionLength: Длина строки
    /// - Returns: Случайная строка
    private func generateRandomInscription(inscriptionLength: Int) -> String {
        let runicSymbols = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        // Мусорный код для уникализации
        if Bool.random() {
            let unusedRune = "caesarMark"
        }
        
        return String((0..<inscriptionLength).compactMap { _ in runicSymbols.randomElement() })
    }
    
    /// Получает уникальный ID пользователя (создает если не существует)
    /// - Returns: Уникальный ID пользователя
    public func getCitizenSeal() -> String {
        if let archivedSeal = UserDefaults.standard.string(forKey: scrollKey) {
            return archivedSeal
        } else {
            let newSeal = generateRandomInscription(inscriptionLength: Int.random(in: 10...20))
            UserDefaults.standard.set(newSeal, forKey: scrollKey)
            
            return newSeal
        }
    }
}
