import SwiftUI
import WebKit
import UIKit
import StoreKit

// MARK: - AmphitheaterView

/// Конфигурация для отображения веб-контента
public struct AmphitheaterView: UIViewRepresentable {
    
    // MARK: - Public Properties
    
    let scrollPath: String
    let allowsRituals: Bool
    let enableRefresh: Bool
    
    // MARK: - Init
    
    public init(scrollPath: String, allowsRituals: Bool = true, enableRefresh: Bool = true) {
        self.scrollPath = scrollPath
        self.allowsRituals = allowsRituals
        self.enableRefresh = enableRefresh
    }
    
    // MARK: - Public Functions
    
    public func makeUIView(context: Context) -> WKWebView {
        let imperiumConfig = WKWebViewConfiguration()
        let imperiumPreferences = WKWebpagePreferences()
        
        // Настройка JavaScript
        imperiumPreferences.allowsContentJavaScript = true
        imperiumConfig.defaultWebpagePreferences = imperiumPreferences
        imperiumConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        // Настройка медиа
        imperiumConfig.allowsInlineMediaPlayback = true
        imperiumConfig.mediaTypesRequiringUserActionForPlayback = []
        imperiumConfig.allowsAirPlayForMediaPlayback = true
        imperiumConfig.allowsPictureInPictureMediaPlayback = true
        
        // Настройка данных сайта
        imperiumConfig.websiteDataStore = WKWebsiteDataStore.default()
        
        // Создание WebView
        let amphitheaterView = WKWebView(frame: .zero, configuration: imperiumConfig)
        
        // Настройка фона (черный)
        amphitheaterView.backgroundColor = .black
        amphitheaterView.scrollView.backgroundColor = .black
        amphitheaterView.isOpaque = false
        
        // Настройка жестов
        amphitheaterView.allowsBackForwardNavigationGestures = allowsRituals
        
        // Используем Desktop Safari User Agent для прохождения Google OAuth
        // Desktop версия обходит блокировку "embedded browsers"
        amphitheaterView.customUserAgent =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
        
        // Настройка координатора
        amphitheaterView.navigationDelegate = context.coordinator
        amphitheaterView.uiDelegate = context.coordinator
        
        // Настройка refresh control
        let imperiumRefreshControl = UIRefreshControl()
        imperiumRefreshControl.tintColor = .white
        imperiumRefreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshScroll(_:)), for: .valueChanged)
        amphitheaterView.scrollView.refreshControl = imperiumRefreshControl
        
        // Сохраняем ссылки в координаторе
        context.coordinator.amphitheaterWebView = amphitheaterView
        context.coordinator.imperiumRefreshControl = imperiumRefreshControl
        
        if let tribuneURL = URL(string: scrollPath) {
            amphitheaterView.load(URLRequest(url: tribuneURL))
        }
        
        return amphitheaterView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // ⚠️ НЕ перезагружаем на каждый апдейт SwiftUI
        // Загружаем только если реально сменился URL
        if uiView.url?.absoluteString != scrollPath, let tribuneURL = URL(string: scrollPath) {
            uiView.load(URLRequest(url: tribuneURL))
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        
        // MARK: - Public Properties
        
        var parent: AmphitheaterView
        weak var amphitheaterWebView: WKWebView?
        weak var imperiumRefreshControl: UIRefreshControl?
        var legionaryWebView: WKWebView? // Временный WebView для OAuth
        
        // MARK: - Init
        
        init(_ parent: AmphitheaterView) {
            self.parent = parent
            super.init()
            
            // Настройка observers для всех событий клавиатуры
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShowInImperium),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardDidShowInImperium),
                name: UIResponder.keyboardDidShowNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHideInImperium),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardDidHideInImperium),
                name: UIResponder.keyboardDidHideNotification,
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        // MARK: - Public Functions
        
        @objc func refreshScroll(_ sender: UIRefreshControl) {
            amphitheaterWebView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.imperiumRefreshControl?.endRefreshing()
            }
        }
        
        // MARK: - Keyboard Handling
        
        // Мягкий viewport refresh без изменения DOM
        private func softViewportRefreshInAmphitheater() {
            guard let consulWebView = amphitheaterWebView else { return }
            
            // Легкий JavaScript - только события, без изменения DOM
            let imperiumJavaScript = """
            (function() {
                // Триггер viewport и window resize событий
                if (window.visualViewport) {
                    window.dispatchEvent(new Event('resize'));
                }
                window.dispatchEvent(new Event('resize'));
                
                // Легкий scroll для триггера reflow
                window.scrollBy(0, 1);
                window.scrollBy(0, -1);
            })();
            """
            
            consulWebView.evaluateJavaScript(imperiumJavaScript, completionHandler: nil)
            
            // Легкий нативный scroll
            let currentPosition = consulWebView.scrollView.contentOffset
            consulWebView.scrollView.setContentOffset(
                CGPoint(x: currentPosition.x, y: currentPosition.y + 1),
                animated: false
            )
            consulWebView.scrollView.setContentOffset(currentPosition, animated: false)
        }
        
        @objc private func keyboardWillShowInImperium(_ notification: Notification) {
            softViewportRefreshInAmphitheater()
        }
        
        @objc private func keyboardDidShowInImperium(_ notification: Notification) {
            // Отложенный refresh после полного показа клавиатуры
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.softViewportRefreshInAmphitheater()
            }
        }
        
        @objc private func keyboardWillHideInImperium(_ notification: Notification) {
            softViewportRefreshInAmphitheater()
        }
        
        @objc private func keyboardDidHideInImperium(_ notification: Notification) {
            // Немедленный refresh
            softViewportRefreshInAmphitheater()
            
            // Вторая попытка после задержки
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.softViewportRefreshInAmphitheater()
            }
            
            // Третья попытка после длинной задержки для упорных случаев
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.softViewportRefreshInAmphitheater()
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        // Обработка навигации
        public func webView(_ consulWebView: WKWebView,
                            decidePolicyFor ritualAction: WKNavigationAction,
                            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let tribuneURL = ritualAction.request.url {
                let scrollPath = tribuneURL.absoluteString
                
                // Если это временный WebView - перехватываем РЕАЛЬНЫЙ URL здесь!
                if consulWebView == legionaryWebView {
                    if !scrollPath.isEmpty && 
                       scrollPath != "about:blank" &&
                       !scrollPath.hasPrefix("about:") {
                        // Загружаем в основной WebView
                        if let primaryWebView = amphitheaterWebView {
                            primaryWebView.load(URLRequest(url: tribuneURL))
                            legionaryWebView = nil
                        }
                        decisionHandler(.cancel)
                        return
                    }
                }
                
                let tribuneScheme = tribuneURL.scheme?.lowercased()
                
                // Открываем внешние схемы в системе
                if let tribuneScheme = tribuneScheme,
                   tribuneScheme != "http", tribuneScheme != "https", tribuneScheme != "about" {
                    UIApplication.shared.open(tribuneURL, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
                
                // OAuth popup - загружаем в том же WebView (со свайпом назад)
                if ritualAction.targetFrame == nil {
                    consulWebView.load(URLRequest(url: tribuneURL))
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
        
        // Обработка дочерних окон - перехватываем URL для основного WebView
        public func webView(_ consulWebView: WKWebView,
                            createWebViewWith imperiumConfig: WKWebViewConfiguration,
                            for ritualAction: WKNavigationAction,
                            windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            // Если URL есть - загружаем в текущий WebView
            if let tribuneURL = ritualAction.request.url, 
               !tribuneURL.absoluteString.isEmpty,
               tribuneURL.absoluteString != "about:blank" {
                consulWebView.load(URLRequest(url: tribuneURL))
                return nil
            }
            
            // Если URL пустой - создаем СКРЫТЫЙ временный WebView
            // Он перехватит URL, который загрузит JavaScript, и передаст в основной WebView
            let tempLegionaryView = WKWebView(frame: .zero, configuration: imperiumConfig)
            tempLegionaryView.navigationDelegate = self
            tempLegionaryView.uiDelegate = self
            tempLegionaryView.isHidden = true
            
            self.legionaryWebView = tempLegionaryView
            return tempLegionaryView
        }
        
        // Закрытие временного WebView
        public func webViewDidClose(_ consulWebView: WKWebView) {
            if consulWebView == legionaryWebView {
                legionaryWebView = nil
            }
        }
        
        // Обработка начала навигации
        public func webView(_ consulWebView: WKWebView, didStartProvisionalNavigation imperiumNavigation: WKNavigation!) {
            // Если это временный WebView - перехватываем РЕАЛЬНЫЙ URL (не about:blank)
            if consulWebView == legionaryWebView, let realTribuneURL = consulWebView.url {
                let scrollPath = realTribuneURL.absoluteString
                
                // Игнорируем пустые URL и about:blank
                if !scrollPath.isEmpty && 
                   scrollPath != "about:blank" &&
                   !scrollPath.hasPrefix("about:") {
                    // Загружаем в основной WebView
                    if let primaryWebView = amphitheaterWebView {
                        primaryWebView.load(URLRequest(url: realTribuneURL))
                        legionaryWebView = nil
                    }
                    return
                }
            }
        }
        
        // Обработка завершения загрузки
        public func webView(_ consulWebView: WKWebView, didFinish imperiumNavigation: WKNavigation!) {
            imperiumRefreshControl?.endRefreshing()
        }
        
        // Обработка ошибок загрузки
        public func webView(_ consulWebView: WKWebView, didFail imperiumNavigation: WKNavigation!, withError consulError: Error) {
            imperiumRefreshControl?.endRefreshing()
        }
        
        // Обработка ошибок загрузки (провизорная навигация)
        public func webView(_ consulWebView: WKWebView, didFailProvisionalNavigation imperiumNavigation: WKNavigation!, withError consulError: Error) {
            // Обработка ошибок
        }
    }
}

// MARK: - SafeAmphitheaterView

/// SwiftUI обертка для AmphitheaterView с отступами от safe area
public struct SafeAmphitheaterView: View {
    
    // MARK: - Public Properties
    
    let scrollPath: String
    let allowsRituals: Bool
    let enableRefresh: Bool
    
    // MARK: - Init
    
    public init(scrollPath: String, allowsRituals: Bool = true, enableRefresh: Bool = true) {
        self.scrollPath = scrollPath
        self.allowsRituals = allowsRituals
        self.enableRefresh = enableRefresh
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Черный фон
            Color.black
                .ignoresSafeArea()
            
            // WebView с отступами от safe area
            AmphitheaterView(
                scrollPath: scrollPath,
                allowsRituals: allowsRituals,
                enableRefresh: enableRefresh
            )
            .ignoresSafeArea(.keyboard)
            .onAppear {
               
                
                // Запрос оценки при третьем запуске
                let imperiumCount = UserDefaults.standard.integer(forKey: "imperiumColosseumCount")
                if imperiumCount == 2 {
                    if let imperiumScene = UIApplication.shared
                        .connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: imperiumScene)
                    }
                }
            }
        }
    }
}
