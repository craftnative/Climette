import Foundation

extension ClothingItemEntity {
    @MainActor public func toDomain() -> Garment {
        return Garment(
            id: id,
            layer: ClothingLayer(rawValue: layerRaw) ?? .base,
            ontology: SystemOntology(rawValue: ontologyRaw) ?? .breathableBase,
            userNickname: userNickname,
            functionalDescriptor: functionalDescriptor
        )
    }
    
    public convenience init(from domain: Garment) {
        self.init(
            id: domain.id,
            layerRaw: domain.layer.rawValue,
            ontologyRaw: domain.ontology.rawValue,
            userNickname: domain.userNickname,
            functionalDescriptor: domain.functionalDescriptor
        )
    }
}
