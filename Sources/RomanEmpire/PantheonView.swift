import SwiftUI

// MARK: - PantheonView

/// Космический фон с движущимися звездами
struct PantheonView: View {
    
    // MARK: - Public Properties
    
    let constellationCount: Int
    let velocity: Double
    
    // MARK: - Private Properties
    
    @State private var celestialBodies: [CelestialOrb] = []
    
    // MARK: - Nested Types
    
    struct CelestialOrb: Identifiable {
        let id = UUID()
        let positionX: CGFloat
        let positionY: CGFloat
        let magnitude: CGFloat
        let luminosity: Double
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { cosmicGeometry in
            ZStack {
                Color.black
                
                ForEach(celestialBodies) { orb in
                    Circle()
                        .fill(Color.white)
                        .frame(width: orb.magnitude, height: orb.magnitude)
                        .opacity(orb.luminosity)
                        .position(x: orb.positionX, y: orb.positionY)
                }
            }
            .onAppear {
                generateCelestialOrbs(in: cosmicGeometry.size)
                animateCelestialOrbs()
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func generateCelestialOrbs(in cosmicDimensions: CGSize) {
        celestialBodies = (0..<constellationCount).map { _ in
            CelestialOrb(
                positionX: CGFloat.random(in: 0...cosmicDimensions.width),
                positionY: CGFloat.random(in: 0...cosmicDimensions.height),
                magnitude: CGFloat.random(in: 1...3),
                luminosity: Double.random(in: 0.3...1.0)
            )
        }
    }
    
    private func animateCelestialOrbs() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                for tribuneIndex in celestialBodies.indices {
                    celestialBodies[tribuneIndex] = CelestialOrb(
                        positionX: celestialBodies[tribuneIndex].positionX + CGFloat(velocity),
                        positionY: celestialBodies[tribuneIndex].positionY,
                        magnitude: celestialBodies[tribuneIndex].magnitude,
                        luminosity: celestialBodies[tribuneIndex].luminosity
                    )
                    
                    // Перемещаем звезды, которые вышли за границы экрана
                    // Используем большое значение для кроссплатформенности
                    if celestialBodies[tribuneIndex].positionX > 1000 {
                        celestialBodies[tribuneIndex] = CelestialOrb(
                            positionX: -10,
                            positionY: celestialBodies[tribuneIndex].positionY,
                            magnitude: celestialBodies[tribuneIndex].magnitude,
                            luminosity: celestialBodies[tribuneIndex].luminosity
                        )
                    }
                }
            }
        }
    }
}
