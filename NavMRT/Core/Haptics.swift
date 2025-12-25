import UIKit
enum Haptics {
  static func tick() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
  static func warn() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}
