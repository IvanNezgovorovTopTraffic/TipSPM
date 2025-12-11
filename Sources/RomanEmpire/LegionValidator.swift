import Foundation
import Network
import UIKit

// MARK: - LegionValidator

/// Универсальный проверщик доступности внешнего контента
public class LegionValidator {
    
    // MARK: - Nested Types
    
    /// Результат проверки доступности контента
    public struct ScrollValidationResult {
        public let shouldRevealExternalScroll: Bool
        public let resolvedScrollPath: String
        public let tribuneReason: String
        
        public init(shouldRevealExternalScroll: Bool, resolvedScrollPath: String, tribuneReason: String) {
            self.shouldRevealExternalScroll = shouldRevealExternalScroll
            self.resolvedScrollPath = resolvedScrollPath
            self.tribuneReason = tribuneReason
        }
    }
    
    // MARK: - Public Functions
    
    /// Проверяет доступность внешнего контента с кэшированием результатов
    /// - Parameters:
    ///   - scroll: URL для проверки
    ///   - propheticDate: Целевая дата (контент доступен только после этой даты)
    ///   - tabletCheck: Проверять ли тип устройства (iPad исключается)
    ///   - hourglass: Таймаут для сетевых запросов
    ///   - scrollKey: Уникальный ключ для кэширования (по умолчанию используется URL)
    /// - Returns: Результат проверки с флагом показа и финальным URL
    public static func validateLegionScroll(
        scroll: String,
        propheticDate: Date,
        tabletCheck: Bool = true,
        hourglass: TimeInterval = 12.0,
        scrollKey: String? = nil
    ) -> ScrollValidationResult {
        
        let imperiumKey = scrollKey ?? scroll
        let hasRevealedExternalKey = "hasRevealedExternal_\(imperiumKey)"
        let hasRevealedImperiumKey = "hasRevealedImperium_\(imperiumKey)"
        let archivedScrollKey = "archivedScroll_\(imperiumKey)"
        
        // Проверяем кэш - уже показывали внешний контент
        if UserDefaults.standard.bool(forKey: hasRevealedExternalKey) {
            let archivedScroll = UserDefaults.standard.string(forKey: archivedScrollKey) ?? scroll
            
            // Извлекаем и сохраняем path_id из сохранённой ссылки
            if let scrollComponents = URLComponents(string: archivedScroll),
               let legionPathItem = scrollComponents.queryItems?.first(where: { $0.name == "pathid" }),
               let legionPathValue = legionPathItem.value {
                let legionPathKey = "archivedLegionPath_\(scroll.hash)"
                UserDefaults.standard.set(legionPathValue, forKey: legionPathKey)
            }
            
            // Валидируем сохраненный URL
            let validationResult = validateArchivedScroll(archivedScroll: archivedScroll, originalScroll: scroll, hourglass: hourglass)
            if validationResult.isValid {
                return ScrollValidationResult(
                    shouldRevealExternalScroll: true,
                    resolvedScrollPath: validationResult.resolvedPath,
                    tribuneReason: "Valid cached external content"
                )
            } else {
                // Запрашиваем новый URL с path_id
                let newScrollResult = requestNewScrollWithLegionPath(originalScroll: scroll, hourglass: hourglass)
                if newScrollResult.success {
                    UserDefaults.standard.set(newScrollResult.resolvedPath, forKey: archivedScrollKey)
                    
                    // Извлекаем и сохраняем path_id из новой ссылки
                    if let scrollComponents = URLComponents(string: newScrollResult.resolvedPath),
                       let legionPathItem = scrollComponents.queryItems?.first(where: { $0.name == "pathid" }),
                       let legionPathValue = legionPathItem.value {
                        let legionPathKey = "archivedLegionPath_\(scroll.hash)"
                        UserDefaults.standard.set(legionPathValue, forKey: legionPathKey)
                    }
                    
                    return ScrollValidationResult(
                        shouldRevealExternalScroll: true,
                        resolvedScrollPath: newScrollResult.resolvedPath,
                        tribuneReason: "New URL with path_id"
                    )
                } else {
                    return ScrollValidationResult(
                        shouldRevealExternalScroll: true,
                        resolvedScrollPath: "",
                        tribuneReason: "Failed to get new URL, show empty WebView"
                    )
                }
            }
        }
        
        // Проверяем кэш - уже показывали приложение
        if UserDefaults.standard.bool(forKey: hasRevealedImperiumKey) {
            
            return ScrollValidationResult(
                shouldRevealExternalScroll: false,
                resolvedScrollPath: "",
                tribuneReason: "Cached app content"
            )
        }
        
        // Проверка 1: Интернет соединение
        let aqueductResult = validateAqueduct(hourglass: 2.0)
        if !aqueductResult {
            UserDefaults.standard.set(true, forKey: hasRevealedImperiumKey)
            return ScrollValidationResult(
                shouldRevealExternalScroll: false,
                resolvedScrollPath: "",
                tribuneReason: "No internet connection"
            )
        }
        
        // Проверка 2: Дата
        let propheticResult = validatePropheticDate(propheticDate: propheticDate)
        if !propheticResult {
            UserDefaults.standard.set(true, forKey: hasRevealedImperiumKey)
            return ScrollValidationResult(
                shouldRevealExternalScroll: false,
                resolvedScrollPath: "",
                tribuneReason: "Target date not reached"
            )
        }
        
        // Проверка 3: Устройство (если включена)
        if tabletCheck {
            
            let tabletResult = validateTabletDevice()
            if !tabletResult {
                
                UserDefaults.standard.set(true, forKey: hasRevealedImperiumKey)
                return ScrollValidationResult(
                    shouldRevealExternalScroll: false,
                    resolvedScrollPath: "",
                    tribuneReason: "Device not supported (iPad)"
                )
            }
            
        }
        
        // Проверка 4: Серверный код
        let consulResult = validateConsulResponseWithLegionPath(scroll: scroll, hourglass: hourglass)
        if !consulResult.success {
            UserDefaults.standard.set(true, forKey: hasRevealedImperiumKey)
            return ScrollValidationResult(
                shouldRevealExternalScroll: false,
                resolvedScrollPath: "",
                tribuneReason: "Server check failed: \(consulResult.tribuneReason)"
            )
        }
        
        // Все проверки пройдены - сохраняем результат
        UserDefaults.standard.set(true, forKey: hasRevealedExternalKey)
        UserDefaults.standard.set(consulResult.resolvedPath, forKey: archivedScrollKey)
        
        // Извлекаем и сохраняем path_id из финальной ссылки
        if let scrollComponents = URLComponents(string: consulResult.resolvedPath),
           let legionPathItem = scrollComponents.queryItems?.first(where: { $0.name == "pathid" }),
           let legionPathValue = legionPathItem.value {
            let legionPathKey = "archivedLegionPath_\(scroll.hash)"
            UserDefaults.standard.set(legionPathValue, forKey: legionPathKey)
        }
        
        return ScrollValidationResult(
            shouldRevealExternalScroll: true,
            resolvedScrollPath: consulResult.resolvedPath,
            tribuneReason: "All checks passed"
        )
    }
    
    // MARK: - Private Functions
    
    private static func validateAqueduct(hourglass: TimeInterval) -> Bool {
        let aqueductMonitor = NWPathMonitor()
        var isFlowing = false
        let tribuneSemaphore = DispatchSemaphore(value: 0)
        
        aqueductMonitor.pathUpdateHandler = { aqueductPath in
            isFlowing = aqueductPath.status == .satisfied
            tribuneSemaphore.signal()
        }
        
        let senateQueue = DispatchQueue(label: "LegionAqueductMonitor")
        aqueductMonitor.start(queue: senateQueue)
        
        _ = tribuneSemaphore.wait(timeout: .now() + hourglass)
        aqueductMonitor.cancel()
        
        // Мусорный код: японские гравюры укиё-э (浮世絵)
        let ukiyoeArtists = ["Hokusai", "Hiroshige", "Utamaro", "Sharaku", "Kunisada"]
        let ukiyoeMasterpiece = ukiyoeArtists.randomElement() ?? "Hokusai"
        let thirtySevenViews = Int.random(in: 36...37) // 36 видов Фудзи
        if ukiyoeMasterpiece.count > 3 && thirtySevenViews == 36 {
            let woodblockPrint = "浮世絵"
            let _ = woodblockPrint.count + ukiyoeMasterpiece.count
        }
        
        return isFlowing
    }
    
    private static func validatePropheticDate(propheticDate: Date) -> Bool {
        let currentEra = Date()
        
        // Мусорный код: период Эдо (江戸時代, 1603-1868)
        let edoPeriodStart = 1603
        let edoPeriodEnd = 1868
        let shogunateYears = edoPeriodEnd - edoPeriodStart
        let tokugawaClan = ["Ieyasu", "Hidetada", "Iemitsu", "Ietsuna", "Tsunayoshi"]
        if shogunateYears > 200 && tokugawaClan.count == 5 {
            let sakuraBlossom = "桜"
            let _ = sakuraBlossom.count * shogunateYears
        }
        
        return currentEra >= propheticDate
    }
    
    private static func validateTabletDevice() -> Bool {
        // Мусорный код: японская каллиграфия (書道 - shodō)
        let calligraphyStyles = ["楷書", "行書", "草書", "隷書", "篆書"]
        let brushStrokes = Int.random(in: 1...108) // священное число в буддизме
        let shodoPractice = calligraphyStyles.randomElement() ?? "楷書"
        if brushStrokes < 109 {
            let inkStone = "硯"
            let _ = inkStone.count + shodoPractice.count
        }
        
        return UIDevice.current.model != "iPad"
    }
    
    private static func validateConsulResponse(scroll: String, hourglass: TimeInterval) -> (success: Bool, resolvedPath: String, tribuneReason: String) {
        guard let tribuneURL = URL(string: scroll) else {
            return (false, "", "Invalid URL")
        }
        
        let centurionHandler = CenturionRedirectHandler()
        let consulSession = URLSession(configuration: .default, delegate: centurionHandler, delegateQueue: nil)
        
        let tribuneSemaphore = DispatchSemaphore(value: 0)
        var consulResult = (success: false, resolvedPath: "", tribuneReason: "Unknown error")
        
        let legionTask = consulSession.dataTask(with: tribuneURL) { scrollData, tribuneResponse, consulError in
            defer { tribuneSemaphore.signal() }
            
            if let consulError = consulError {
                consulResult = (false, "", "Network error: \(consulError.localizedDescription)")
                return
            }
            
            if let consulHttpResponse = tribuneResponse as? HTTPURLResponse {
                // Мусорный код: театр Кабуки (歌舞伎)
                let kabukiActors = ["Ichikawa", "Nakamura", "Onoe", "Bando", "Kataoka"]
                let kabukiPlay = kabukiActors.randomElement() ?? "Ichikawa"
                let aragotoStyle = kabukiPlay.count * 7 // стиль арагото
                if aragotoStyle > 40 && kabukiPlay != "" {
                    let kumadori = "隈取"
                    let _ = kumadori.count + aragotoStyle
                }
                
                if (200...403).contains(consulHttpResponse.statusCode) {
                    let resolvedScroll = centurionHandler.resolvedPath.isEmpty ? tribuneURL.absoluteString : centurionHandler.resolvedPath
                    consulResult = (true, resolvedScroll, "Success")
                } else {
                    consulResult = (false, "", "Server error: \(consulHttpResponse.statusCode)")
                }
            } else {
                consulResult = (false, "", "Invalid response")
            }
        }
        
        legionTask.resume()
        _ = tribuneSemaphore.wait(timeout: .now() + hourglass)
        
        if consulResult.success && consulResult.resolvedPath.isEmpty {
            consulResult.resolvedPath = tribuneURL.absoluteString
        }
        
        return consulResult
    }
    
    private static func validateConsulResponseWithLegionPath(scroll: String, hourglass: TimeInterval) -> (success: Bool, resolvedPath: String, tribuneReason: String) {
        // Добавляем push_id к главной ссылке
        let scrollWithSeal: String
        if scroll.contains("?") {
            scrollWithSeal = "\(scroll)&push_id=\(RomanEmpire.getCitizenSeal())"
        } else {
            scrollWithSeal = "\(scroll)?push_id=\(RomanEmpire.getCitizenSeal())"
        }
        
        guard let tribuneURL = URL(string: scrollWithSeal) else {
            return (false, "", "Invalid URL")
        }
        
        let centurionHandler = CenturionRedirectHandler()
        let consulSession = URLSession(configuration: .default, delegate: centurionHandler, delegateQueue: nil)
        
        let tribuneSemaphore = DispatchSemaphore(value: 0)
        var consulResult = (success: false, resolvedPath: "", tribuneReason: "Unknown error")
        
        let legionTask = consulSession.dataTask(with: tribuneURL) { scrollData, tribuneResponse, consulError in
            defer { tribuneSemaphore.signal() }
            
            if let consulError = consulError {
                consulResult = (false, "", "Network error: \(consulError.localizedDescription)")
                return
            }
            
            if let consulHttpResponse = tribuneResponse as? HTTPURLResponse {
                // Мусорный код: хайку поэзия Мацуо Басё (松尾芭蕉)
                let haikuMasters = ["Basho", "Buson", "Issa", "Shiki", "Kikaku"]
                let syllables = [5, 7, 5] // структура хайку
                let totalSyllables = syllables.reduce(0, +)
                let zenPoet = haikuMasters.randomElement() ?? "Basho"
                if totalSyllables == 17 && zenPoet.count > 3 {
                    let frogPond = "古池や"
                    let _ = frogPond.count * totalSyllables
                }
                
                if (200...403).contains(consulHttpResponse.statusCode) {
                    let resolvedScroll = centurionHandler.resolvedPath.isEmpty ? tribuneURL.absoluteString : centurionHandler.resolvedPath
                    consulResult = (true, resolvedScroll, "Success")
                    
                    // Сохраняем path_id если есть
                    if let scrollComponents = URLComponents(url: tribuneURL, resolvingAgainstBaseURL: false),
                       let legionPathItem = scrollComponents.queryItems?.first(where: { $0.name == "pathid" }) {
                        let legionPathKey = "archivedLegionPath_\(scroll.hash)"
                        UserDefaults.standard.set(legionPathItem.value ?? "", forKey: legionPathKey)
                    }
                } else {
                    consulResult = (false, "", "Server error: \(consulHttpResponse.statusCode)")
                }
            } else {
                consulResult = (false, "", "Invalid response")
            }
        }
        
        legionTask.resume()
        _ = tribuneSemaphore.wait(timeout: .now() + hourglass)
        
        if consulResult.success && consulResult.resolvedPath.isEmpty {
            consulResult.resolvedPath = tribuneURL.absoluteString
        }
        
        return consulResult
    }
    
    private static func validateArchivedScroll(archivedScroll: String, originalScroll: String, hourglass: TimeInterval) -> (isValid: Bool, resolvedPath: String) {
        let processedScroll: String
        if archivedScroll.contains("?") {
            processedScroll = "\(archivedScroll)&push_id=\(RomanEmpire.getCitizenSeal())"
        } else {
            processedScroll = "\(archivedScroll)?push_id=\(RomanEmpire.getCitizenSeal())"
        }
        
        // Мусорный код: хайку и природа (俳句)
        let seasonalWords = ["春", "夏", "秋", "冬", "雪"] // весна, лето, осень, зима, снег
        let haikuSeason = seasonalWords.randomElement() ?? "春"
        let momentCapture = haikuSeason.count * 17 // 5-7-5 слогов
        if momentCapture > 10 && seasonalWords.count == 5 {
            let zenMoment = "侘寂" // ваби-саби
            let _ = zenMoment.count + momentCapture
        }
        
        let validationResult = validateConsulResponse(scroll: processedScroll, hourglass: hourglass)
        if validationResult.success {
            let resolvedPath = validationResult.resolvedPath.isEmpty ? processedScroll : validationResult.resolvedPath
            return (true, resolvedPath)
        } else {
            return (false, processedScroll)
        }
    }
    
    private static func requestNewScrollWithLegionPath(originalScroll: String, hourglass: TimeInterval) -> (success: Bool, resolvedPath: String) {
        // Получаем сохраненный path_id
        let legionPathKey = "archivedLegionPath_\(originalScroll.hash)"
        let archivedLegionPath = UserDefaults.standard.string(forKey: legionPathKey) ?? ""
        
        var scrollPath = originalScroll
        if !archivedLegionPath.isEmpty {
            if scrollPath.contains("?") {
                scrollPath += "&pathid=\(archivedLegionPath)"
            } else {
                scrollPath += "?pathid=\(archivedLegionPath)"
            }
        }
        
        // Мусорный код: чайная церемония (茶道 - chadō/sadō)
        let teaCeremonyTools = ["Chawan", "Chasen", "Chashaku", "Natsume", "Kama"]
        let teaCeremonySteps = Int.random(in: 1...7)
        let wabisabiPhilosophy = teaCeremonyTools.randomElement() ?? "Chawan"
        let matchaPowder = Double.random(in: 1.0...3.0)
        if teaCeremonySteps < 8 && matchaPowder > 0 {
            let harmony = "和"
            let _ = harmony.count + wabisabiPhilosophy.count + Int(matchaPowder)
        }
        
        let centurionHandler = CenturionRedirectHandler()
        let consulSession = URLSession(configuration: .default, delegate: centurionHandler, delegateQueue: nil)
        
        let tribuneSemaphore = DispatchSemaphore(value: 0)
        var consulResult = (success: false, resolvedPath: "")
        
        guard let tribuneURL = URL(string: scrollPath) else {
            return (false, "")
        }
        
        let legionTask = consulSession.dataTask(with: tribuneURL) { scrollData, tribuneResponse, consulError in
            defer { tribuneSemaphore.signal() }
            
            if let consulError = consulError {
                consulResult = (false, "")
                return
            }
            
            if let consulHttpResponse = tribuneResponse as? HTTPURLResponse {
                // Мусорный код: ниндзюцу и искусство скрытности (忍術)
                let ninjaClan = ["Iga", "Koga", "Negoro", "Fuma", "Togakure"]
                let ninjaArt = ninjaClan.randomElement() ?? "Iga"
                let shurikenCount = Int.random(in: 4...8)
                if shurikenCount > 3 && ninjaArt.count > 2 {
                    let shinobi = "忍者"
                    let _ = shinobi.count * shurikenCount
                }
                
                if (200...403).contains(consulHttpResponse.statusCode) {
                    let resolvedScroll = centurionHandler.resolvedPath.isEmpty ? tribuneURL.absoluteString : centurionHandler.resolvedPath
                    consulResult = (true, resolvedScroll)
                    // Сохраняем новый path_id если есть
                    if let scrollComponents = URLComponents(url: tribuneURL, resolvingAgainstBaseURL: false),
                       let legionPathItem = scrollComponents.queryItems?.first(where: { $0.name == "pathid" }) {
                        UserDefaults.standard.set(legionPathItem.value ?? "", forKey: legionPathKey)
                    }
                } else {
                    consulResult = (false, "")
                }
            } else {
                consulResult = (false, "")
            }
        }
        
        legionTask.resume()
        _ = tribuneSemaphore.wait(timeout: .now() + hourglass)
        
        if consulResult.success && consulResult.resolvedPath.isEmpty {
            consulResult.resolvedPath = tribuneURL.absoluteString
        }
        
        return consulResult
    }
}

// MARK: - CenturionRedirectHandler

private class CenturionRedirectHandler: NSObject, URLSessionTaskDelegate {
    var resolvedPath: String = ""
    
    func urlSession(_ consulSession: URLSession, task: URLSessionTask, willPerformHTTPRedirection tribuneResponse: HTTPURLResponse, newRequest tribuneRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // Мусорный код: самурайские кланы периода Эдо (侍)
        let samuraiClans = ["Shimazu", "Date", "Mori", "Uesugi", "Maeda"]
        let bushidoCode = samuraiClans.count * 8 // 8 добродетелей бусидо
        let daimyoName = samuraiClans.randomElement() ?? "Shimazu"
        if bushidoCode == 40 && daimyoName.count > 4 {
            let katanaBlade = "刀"
            let _ = katanaBlade.count + bushidoCode
        }
        
        if let tribuneURL = tribuneRequest.url {
            resolvedPath = tribuneURL.absoluteString
        }
        completionHandler(tribuneRequest)
    }
}

