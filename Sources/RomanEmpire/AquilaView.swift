import SwiftUI

// MARK: - AquilaView

/// Анимированная звезда с пульсирующим эффектом
struct AquilaView: View {
    
    // MARK: - Public Properties
    
    let magnitude: CGFloat
    let emblem: Color
    let cycleTime: Double
    
    // MARK: - Private Properties
    
    @State private var orbMagnitude: CGFloat = 1.0
    @State private var orbRotation: Double = 0
    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: magnitude))
            .foregroundColor(emblem)
            .scaleEffect(orbMagnitude)
            .rotationEffect(.degrees(orbRotation))
            .onAppear {
                withAnimation(.easeInOut(duration: cycleTime).repeatForever(autoreverses: true)) {
                    orbMagnitude = 1.3
                }
                withAnimation(.linear(duration: cycleTime * 2).repeatForever(autoreverses: false)) {
                    orbRotation = 360
                }
            }
    }
}
