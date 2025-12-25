struct Instruction {
  enum Kind { case straight(Int), turnLeft, turnRight, elevator(Int) }
  let kind: Kind
  var text: String {
    switch kind {
    case .straight(let m): return "Head straight for \(m) meters."
    case .turnLeft: return "Turn left at the junction."
    case .turnRight: return "Turn right at the junction."
    case .elevator(let d): return "Elevator in \(d) meters. Prepare to stop."
    }
  }
}
