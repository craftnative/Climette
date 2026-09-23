import XCTest

extension XCUIApplication {
    /// Ejecuta una auditoría de accesibilidad estándar capturando y detallando
    /// en la consola de depuración cualquier fallo reportado por el sistema.
    func performStandardAccessibilityAudit() throws {
        try performAccessibilityAudit(for: .all.subtracting([.contrast, .textClipped, .hitRegion])) { issue in
            
            // Falso positivo conocido: El OCR detecta el texto de la hora del DatePicker
            // pero Apple lo mapea en el 'value' del elemento, no como un Text independiente.
            if issue.compactDescription == "Potentially inaccessible text" && issue.element == nil {
                return true
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
            return false
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
        
        // Se fuerza la configuración regional en español para sincronizar la UI del App con los literales del bundle de UI Tests
        app.launchArguments = ["-resetOnboarding", "-AppleLanguages", "(es)", "-AppleLocale", "es_ES"]
        app.launch()

        // Paso 1: Perfil Térmico
        XCTAssertTrue(app.staticTexts[String(localized: "Sensibilidad Térmica")].waitForExistence(timeout: 5))
        try app.performStandardAccessibilityAudit()

        let nextButton = app.buttons[String(localized: "Siguiente")]
        nextButton.tap()

        // Paso 2: Ubicación
        XCTAssertTrue(app.staticTexts[String(localized: "Condiciones Locales")].waitForExistence(timeout: 5))
        try app.performStandardAccessibilityAudit()

        // Modo manual activo por defecto con campo vacío: botón siguiente bloqueado
        XCTAssertFalse(nextButton.isEnabled)

        let cityTextField = app.textFields[String(localized: "Buscar ubicación")]
        cityTextField.tap()
        cityTextField.typeText("Madrid\n")
        XCTAssertTrue(nextButton.isEnabled)
        
        nextButton.tap()

        // Paso 3: Rutina
        XCTAssertTrue(app.staticTexts[String(localized: "Rutina")].waitForExistence(timeout: 5))
        try app.performStandardAccessibilityAudit()

        let startButton = app.buttons[String(localized: "Comenzar")]
        XCTAssertTrue(startButton.isEnabled)
        startButton.tap()

        // Pantalla Principal
        XCTAssertTrue(app.staticTexts[String(localized: "Pantalla Principal de Climette")].waitForExistence(timeout: 5))
    }
}
