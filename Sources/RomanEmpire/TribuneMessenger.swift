import Foundation
import UIKit

// MARK: - TribuneMessenger

/// Менеджер для показа кастомных alert'ов
public final class TribuneMessenger {
    
    // MARK: - Public Properties
    
    public static let shared = TribuneMessenger()
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public Functions
    
    /// Показывает alert для уведомлений с переходом в настройки
    public func summonHeraldAlert() {
        let tribuneAlert = UIAlertController(
            title: "Notification are disabled",
            message: "To receive notifications, please enable them in sttings.",
            preferredStyle: .alert
        )
        
        guard
            let imperiumScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let consulVC = imperiumScene.windows
                .first(where: { $0.isKeyWindow })?.rootViewController
        else {
            return
        }
        
        tribuneAlert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let senateSettingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(senateSettingsURL) {
                UIApplication.shared.open(senateSettingsURL)
            }
        })
        
        tribuneAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        consulVC.present(tribuneAlert, animated: true)
    }
    
    /// Показывает кастомный alert с настраиваемыми параметрами
    /// - Parameters:
    ///   - proclamation: Заголовок alert'а
    ///   - decree: Сообщение alert'а
    ///   - primaryDecree: Текст основной кнопки
    ///   - secondaryDecree: Текст вторичной кнопки (опционально)
    ///   - primaryRitual: Действие при нажатии на основную кнопку
    ///   - secondaryRitual: Действие при нажатии на вторичную кнопку (опционально)
    public func summonTribuneMessage(
        proclamation: String,
        decree: String,
        primaryDecree: String,
        secondaryDecree: String? = nil,
        primaryRitual: (() -> Void)? = nil,
        secondaryRitual: (() -> Void)? = nil
    ) {
        let tribuneAlert = UIAlertController(
            title: proclamation,
            message: decree,
            preferredStyle: .alert
        )
        
        guard
            let imperiumScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let consulVC = imperiumScene.windows.first?.rootViewController
        else {
            
            return
        }
        
        // Основная кнопка
        tribuneAlert.addAction(UIAlertAction(title: primaryDecree, style: .default) { _ in
            primaryRitual?()
            
        })
        
        // Вторичная кнопка (если указана)
        if let secondaryProclamation = secondaryDecree {
            tribuneAlert.addAction(UIAlertAction(title: secondaryProclamation, style: .cancel) { _ in
                secondaryRitual?()
                
            })
        }
        
        consulVC.present(tribuneAlert, animated: true)
        
    }
    
    /// Показывает alert с подтверждением действия
    /// - Parameters:
    ///   - proclamation: Заголовок alert'а
    ///   - decree: Сообщение alert'а
    ///   - affirmDecree: Текст кнопки подтверждения (по умолчанию "OK")
    ///   - vetoDecree: Текст кнопки отмены (по умолчанию "Cancel")
    ///   - onAffirm: Действие при подтверждении
    ///   - onVeto: Действие при отмене (опционально)
    public func summonConfirmationEdict(
        proclamation: String,
        decree: String,
        affirmDecree: String = "OK",
        vetoDecree: String = "Cancel",
        onAffirm: @escaping () -> Void,
        onVeto: (() -> Void)? = nil
    ) {
        summonTribuneMessage(
            proclamation: proclamation,
            decree: decree,
            primaryDecree: affirmDecree,
            secondaryDecree: vetoDecree,
            primaryRitual: onAffirm,
            secondaryRitual: onVeto
        )
    }
}
