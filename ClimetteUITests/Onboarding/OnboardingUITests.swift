import XCTest

final class OnboardingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingFlowAndAccessibility() throws {
        let app = XCUIApplication()
        // Sobrescribe UserDefaults para forzar el inicio en el Onboarding
        app.launchArguments = ["-hasCompletedOnboarding", "false"]
        app.launch()

        // Paso 1: Perfil Térmico
        XCTAssertTrue(app.staticTexts["Sensibilidad Térmica"].waitForExistence(timeout: 2))
        
        // Ejecuta la auditoría automática nativa de Apple (Hit targets, Contrastes, Dynamic Type, Labels)
        try app.performAccessibilityAudit() 

        let nextButton = app.buttons["Ir al siguiente paso"]
        nextButton.tap()

        // Paso 2: Ubicación
        XCTAssertTrue(app.staticTexts["Condiciones Locales"].waitForExistence(timeout: 2))
        try app.performAccessibilityAudit()

        // Validar bloqueo del botón en modo manual sin texto
        app.segmentedControls["Selección del origen de datos de ubicación"].buttons["Ingreso Manual"].tap()
        XCTAssertFalse(nextButton.isEnabled)

        let cityTextField = app.textFields["Nombre de la ciudad"]
        cityTextField.tap()
        cityTextField.typeText("Madrid\n")
        XCTAssertTrue(nextButton.isEnabled)
        
        nextButton.tap()

        // Paso 3: Rutina
        XCTAssertTrue(app.staticTexts["Rutina"].waitForExistence(timeout: 2))
        try app.performAccessibilityAudit()

        let startButton = app.buttons["Comenzar la aplicación"]
        XCTAssertTrue(startButton.isEnabled)
        startButton.tap()

        // Validar finalización y navegación hacia la vista principal
        XCTAssertTrue(app.staticTexts["Pantalla Principal de Climette"].waitForExistence(timeout: 2))
    }
}
