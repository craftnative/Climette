import AppIntents

public struct ClimetteShortcutsProvider: AppShortcutsProvider {
    
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetClothingRecommendationIntent(),
            phrases: [
                "Clima en \(.applicationName)",
                "Qué ropa me pongo con \(.applicationName)",
                "Recomendación del día en \(.applicationName)",
                "Qué me pongo hoy en \(.applicationName)",
                "Consultar recomendación para mañana por la tarde en \(.applicationName)",
                "Qué ropa necesito para el clima de hoy en \(.applicationName)"
            ],
            shortTitle: "Recomendación de Ropa",
            systemImageName: "tshirt"
        )
        
        AppShortcut(
            intent: SaveDailyFeedbackIntent(),
            phrases: [
                "Registrar mi sensación en \(.applicationName)",
                "Guardar la ropa de hoy en \(.applicationName)",
                "Grabar cómo estuve hoy en \(.applicationName)"
            ],
            shortTitle: "Registrar Sensación",
            systemImageName: "thermometer.sun"
        )
    }
}
