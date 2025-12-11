import SwiftUI

// MARK: - ForumView

/// Галактика с вращающимися элементами
struct ForumView: View {
    
    // MARK: - Public Properties
    
    let citizenCount: Int
    let arena: CGFloat
    let banners: [Color]
    
    // MARK: - Private Properties
    
    @State private var orbitalRotation: Double = 0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            ForEach(0..<citizenCount, id: \.self) { tribuneIndex in
                Circle()
                    .fill(banners[tribuneIndex % banners.count])
                    .frame(width: 20, height: 20)
                    .offset(x: arena * 0.4)
                    .rotationEffect(.degrees(Double(tribuneIndex) * 360.0 / Double(citizenCount)))
                    .rotationEffect(.degrees(orbitalRotation))
            }
        }
        .frame(width: arena, height: arena)
        .onAppear {
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                orbitalRotation = 360
            }
        }
    }
}
