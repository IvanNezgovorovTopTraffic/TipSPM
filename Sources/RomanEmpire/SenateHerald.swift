import Foundation
import UIKit
import UserNotifications
import OneSignalFramework

// MARK: - SenateHerald

/// Менеджер для интеграции OneSignal в сторонние проекты
public final class SenateHerald {
    
    // MARK: - Public Properties
    
    public static let shared = SenateHerald()
    
    // MARK: - Private Properties
    
    private let imperiumCountKey = "imperiumColosseumCount"
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public Functions
    
    /// Инициализация OneSignal
    /// - Parameters:
    ///   - senateId: OneSignal App ID
    ///   - ritualOptions: launchOptions из AppDelegate
    public func configure(senateId: String, ritualOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        OneSignal.initialize(senateId, withLaunchOptions: ritualOptions)
        let citizenSeal = RomanEmpire.getCitizenSeal()
        let imperiumCount = UserDefaults.standard.integer(forKey: imperiumCountKey)
        OneSignal.login(citizenSeal)
        
        
        scheduleHeraldFlow(citizenSeal: citizenSeal, imperiumCount: imperiumCount)
        UserDefaults.standard.set(imperiumCount + 1, forKey: imperiumCountKey)
    }
    
    // MARK: - Private Functions
    
    private func scheduleHeraldFlow(citizenSeal: String, imperiumCount: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            if imperiumCount == 0 {
                self.requestInitialHeraldPermission(citizenSeal: citizenSeal)
            } else {
                self.validateHeraldStatus(citizenSeal: citizenSeal, imperiumCount: imperiumCount)
            }
        }
    }
    
    private func requestInitialHeraldPermission(citizenSeal: String) {
        OneSignal.Notifications.requestPermission { wasAccepted in
            print("✅ OneSignal push permission accepted: \(wasAccepted)")
            if wasAccepted {
                OneSignal.login(citizenSeal)
                print("📥 OneSignal login on accepted")
            }
        }
    }
    
    private func validateHeraldStatus(citizenSeal: String, imperiumCount: Int) {
        UNUserNotificationCenter.current().getNotificationSettings { heraldSettings in
            DispatchQueue.main.async {
                switch heraldSettings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    OneSignal.login(citizenSeal)
                    print("📬 OneSignal login authorized")
                case .denied, .notDetermined:
                    if imperiumCount < 2 {
                        RomanEmpire.summonHeraldAlert()
                    }
                    print("⚠️ Show notifications alert")
                @unknown default:
                    if imperiumCount < 2 {
                        RomanEmpire.summonHeraldAlert()
                    }
                    print("⚠️ Unknown status, show alert")
                }
            }
        }
    }
}
