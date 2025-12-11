import XCTest
@testable import RomanEmpire

final class RomanEmpireTests: XCTestCase {
    
    func testColosseumScreenCreation() throws {
        // Тест проверяет создание splash screen с настройками по умолчанию
        let colosseumScreen = RomanEmpire.createColosseumScreen()
        XCTAssertNotNil(colosseumScreen)
        
        // Тест с кастомными цветами
        let customColosseum = RomanEmpire.createColosseumScreen(
            imperiumColors: [.red, .orange, .yellow],
            inscriptionColor: .black,
            orbColor: .blue,
            inscriptionText: "Загрузка..."
        )
        XCTAssertNotNil(customColosseum)
    }
    
    func testRomanEmpireInitialization() throws {
        // Тест проверяет, что пакет может быть импортирован и использован
        let aquilaView = RomanEmpire.createAquilaEmblem()
        XCTAssertNotNil(aquilaView)
        
        let forumView = RomanEmpire.createForum()
        XCTAssertNotNil(forumView)
        
        let pantheonView = RomanEmpire.createPantheon()
        XCTAssertNotNil(pantheonView)
    }
    
    func testAquilaWithCustomParameters() throws {
        let customAquila = RomanEmpire.createAquilaEmblem(
            magnitude: 100,
            emblem: .red,
            cycleTime: 2.0
        )
        XCTAssertNotNil(customAquila)
    }
    
    func testForumWithCustomParameters() throws {
        let customForum = RomanEmpire.createForum(
            citizenCount: 12,
            arena: 300,
            banners: [.green, .orange, .cyan]
        )
        XCTAssertNotNil(customForum)
    }
    
    func testPantheonWithCustomParameters() throws {
        let customPantheon = RomanEmpire.createPantheon(
            constellationCount: 100,
            velocity: 3.0
        )
        XCTAssertNotNil(customPantheon)
    }
}

