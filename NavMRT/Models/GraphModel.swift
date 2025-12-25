import Foundation

struct Graph: Decodable {
    struct Node: Decodable {
        let id: String
        let x: Double
        let y: Double
        let floor: String
        let type: String?
    }
    struct Edge: Decodable {
        let from: String
        let to: String
        let len: Double
        let attrs: Attrs
        
        struct Attrs: Decodable {
            let tactile: Bool?
            let stairs: Bool?
            let elevator: Bool?
        }
    }
    let nodes: [Node]
    let edges: [Edge]
}
// Helper for attrs
struct AnyDecodable: Decodable {
    let value: Any
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self) {
            value = v
            return
        }
        if let v = try? c.decode(Double.self) {
            value = v
            return
        }
        if let v = try? c.decode(Int.self) {
            value = v
            return
        }
        if let v = try? c.decode(String.self) {
            value = v
            return
        }
        if let v = try? c.decode([String: AnyDecodable].self) {
            value = v
            return
        }
        if let v = try? c.decode([AnyDecodable].self) {
            value = v
            return
        }
        throw DecodingError.typeMismatch(
            AnyDecodable.self,
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported"
            )
        )
    }
}
