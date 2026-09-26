import AppIntents

public struct ClimetteShortcutsProvider: AppShortcutsProvider {
    
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetClothingRecommendationIntent(),
            phrases: [
                "Recomendación de ropa para \(\.$targetDay) en \(.applicationName)",
                "Qué me pongo \(\.$targetDay) en \(.applicationName)",
                "Qué me puse \(\.$targetDay) en \(.applicationName)",
                "Qué ropa me puse \(\.$targetDay) con \(.applicationName)"
            ],
            shortTitle: "Recomendación de Ropa",
            systemImageName: "tshirt"
        )
        
        AppShortcut(
            intent: SaveDailyFeedbackIntent(),
            phrases: [
                "Registrar sensación térmica de hoy en \(.applicationName)",
                "Sensación térmica de hoy en \(.applicationName)",
                "Sensación de ropa de hoy en \(.applicationName)",
                "Registrar mi sensación en \(.applicationName)"
            ],
            shortTitle: "Registrar Sensación",
            systemImageName: "thermometer.sun"
        )
    }
}
