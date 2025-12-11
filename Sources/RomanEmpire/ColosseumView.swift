import SwiftUI

// MARK: - ColosseumView

/// Красивый splash screen с градиентом и анимированным лоадером
struct ColosseumView: View {
    
    // MARK: - Public Properties
    
    let imperiumColors: [Color]
    let inscriptionColor: Color
    let orbColor: Color
    let inscriptionText: String
    
    // MARK: - Private Properties
    
    @State private var orbRotation: Double = 0
    @State private var orbMagnitude: CGFloat = 1.0
    @State private var inscriptionOpacity: Double = 0.8
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: imperiumColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Анимированный лоадер
                ZStack {
                    // Внешний круг
                    Circle()
                        .stroke(orbColor.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    // Внутренний круг с анимацией
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            orbColor,
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round
                            )
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(orbRotation))
                        .scaleEffect(orbMagnitude)
                }
                
                // Текст загрузки
                Text(inscriptionText)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(inscriptionColor)
                    .opacity(inscriptionOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            startImperiumAnimations()
        }
    }
    
    // MARK: - Private Functions
    
    private func startImperiumAnimations() {
        // Анимация вращения лоадера
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            orbRotation = 360
        }
        
        // Анимация пульсации лоадера
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            orbMagnitude = 1.2
        }
        
        // Анимация мигания текста
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            inscriptionOpacity = 0.3
        }
    }
}
