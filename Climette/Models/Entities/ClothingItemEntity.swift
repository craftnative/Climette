import Foundation
import SwiftData

@Model
public final class ClothingItemEntity {
    public var id: UUID = UUID()
    public var layerRaw: String = ""
    public var ontologyRaw: String = ""
    public var userNickname: String?
    public var functionalDescriptor: String = ""

    public init(
        id: UUID = UUID(),
        layerRaw: String,
        ontologyRaw: String,
        userNickname: String? = nil,
        functionalDescriptor: String
    ) {
        self.id = id
        self.layerRaw = layerRaw
        self.ontologyRaw = ontologyRaw
        self.userNickname = userNickname
        self.functionalDescriptor = functionalDescriptor
    }
}
