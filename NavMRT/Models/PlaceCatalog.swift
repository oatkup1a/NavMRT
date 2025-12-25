import Foundation

struct PlaceInfo: Decodable {
    let name: String
    let category: String
    let startAllowed: Bool
    let destAllowed: Bool
}

typealias PlaceCatalog = [String: PlaceInfo]

