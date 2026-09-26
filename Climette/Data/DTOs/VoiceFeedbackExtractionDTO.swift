import Foundation
import FoundationModels

@Generable
public struct VoiceFeedbackExtractionDTO: Sendable {
    
    @Guide(description: "El momento del día al que se refiere el usuario. Si no especifica, asume todo el día.")
    public var evaluationPeriod: DayEvaluationPeriod
    
    @Guide(description: "La sensación térmica real expresada por el usuario.")
    public var perception: ThermalPerception
    
    @Guide(description: "Verdadero si el usuario indica que pasó mucho tiempo en un espacio interior cerrado o climatizado (ej. oficina, casa, centro comercial). Falso en caso contrario.")
    public var isIndoorDistortion: Bool
    
    @Guide(description: "Lista de prendas que el usuario describe haber llevado puestas inicialmente. Deben ser nombres descriptivos genéricos (ej. 'camiseta de manga corta', 'vaqueros', 'chaqueta'). Límite máximo: 15 prendas.")
    public var wornGarmentNames: [String]
    
    @Guide(description: "Indica si el usuario tuvo que ponerse o quitarse ropa debido al frío o calor. Nulo si no menciona ajustes.")
    public var physicalReaction: PhysicalReaction?
    
    @Guide(description: "Nombres de las prendas que el usuario se añadió o se quitó para ajustar su temperatura. Vacío si no hubo cambios. Límite máximo: 5 prendas.")
    public var adjustedGarmentNames: [String]
    
    @Guide(description: "Cómo se sintió el usuario después de ajustarse la ropa (ponerse o quitarse capas). Nulo si no especifica o no hubo ajuste.")
    public var postAdjustmentState: PostAdjustmentState?
}
