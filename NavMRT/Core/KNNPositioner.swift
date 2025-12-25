struct KNNPositioner {
  static func estimate(current: [String: Double], dataset: [Fingerprint], k: Int = 1)
  -> (x: Double, y: Double, floor: String)? {
    guard !dataset.isEmpty else { return nil }
    func dist(_ a: [String: Double], _ b: [String:Int]) -> Double {
      let keys = Set(a.keys).union(b.keys)
      return keys.reduce(0.0) { s, k in
        let va = a[k] ?? -100
        let vb = Double(b[k] ?? -100)
        return s + abs(va - vb)
      }
    }
    let top = dataset.map { ($0, dist(current, $0.rssi)) }
      .sorted { $0.1 < $1.1 }
      .prefix(k)
    let c = Double(top.count)
    let x = top.reduce(0.0) { $0 + $1.0.loc.x } / c
    let y = top.reduce(0.0) { $0 + $1.0.loc.y } / c
    return (x, y, top.first!.0.loc.floor)
  }
}
