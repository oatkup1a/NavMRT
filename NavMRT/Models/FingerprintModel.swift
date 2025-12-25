import Foundation
struct Fingerprint: Decodable {
  struct Loc: Decodable { let x: Double; let y: Double; let floor: String }
  let loc: Loc
  let rssi: [String:Int] // "uuid:major:minor" -> dBm
  let label: String?
}
