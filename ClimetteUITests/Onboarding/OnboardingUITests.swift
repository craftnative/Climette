import XCTest

extension XCUIApplication {
    /// Ejecuta una auditoría de accesibilidad estándar capturando y detallando
    /// en la consola de depuración cualquier fallo reportado por el sistema.
    func performStandardAccessibilityAudit() throws {
        try performAccessibilityAudit(for: .all.subtracting([.contrast, .textClipped, .hitRegion])) { issue in
            
            // Falso positivo conocido: El OCR detecta el texto de la hora del DatePicker
            // pero Apple lo mapea en el 'value' del elemento, no como un Text independiente.
            if issue.compactDescription == "Potentially inaccessible text" && issue.element == nil {
                return true // 'true' instruye al test a ignorar esta infracción
            }
            
            print("\n--- 🛑 DETALLE DE AUDITORÍA DE ACCESIBILIDAD ---")
            print("Descripción: \(issue.description)")
            if let element = issue.element {
                print("Elemento: \(element.debugDescription)")
                print("Label: '\(element.label)'")
                print("Value: '\(String(describing: element.value))'")
                print("Frame: \(element.frame)")
            } else {
                print("Elemento: (null) - Nodo no mapeado en el árbol de accesibilidad")
            }
            print("-----------------------------------------------\n")
            return false // 'false' reporta el fallo y detiene el test
        }
    }
}

final class OnboardingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingFlowAndAccessibility() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding"]
        app.launch()
        app.launch()

        // Paso 1: Perfil Térmico
        XCTAssertTrue(app.staticTexts["Sensibilidad Térmica"].waitForExistence(timeout: 2))
        try app.performStandardAccessibilityAudit()

        let nextButton = app.buttons["Siguiente"]
        nextButton.tap()

        // Paso 2: Ubicación
        XCTAssertTrue(app.staticTexts["Condiciones Locales"].waitForExistence(timeout: 2))
        try app.performStandardAccessibilityAudit()

        // Modo manual activo por defecto con campo vacío: botón siguiente bloqueado
        XCTAssertFalse(nextButton.isEnabled)

        let cityTextField = app.textFields["Buscar ubicación"]
        cityTextField.tap()
        cityTextField.typeText("Madrid\n")
        XCTAssertTrue(nextButton.isEnabled)
        
        nextButton.tap()

        // Paso 3: Rutina
        XCTAssertTrue(app.staticTexts["Rutina"].waitForExistence(timeout: 2))
        try app.performStandardAccessibilityAudit()

        let startButton = app.buttons["Comenzar"]
        XCTAssertTrue(startButton.isEnabled)
        startButton.tap()

        // Pantalla Principal
        XCTAssertTrue(app.staticTexts["Pantalla Principal de Climette"].waitForExistence(timeout: 2))
    }
}
