import Foundation
import Combine

final class MockBeaconManager: ObservableObject {
    @Published var latest: [BeaconReading] = []

    private var timer: Timer?
    private var t: Double = 0
    private(set) var isRunning = false

    func start() {
        guard !isRunning else {
            print("MockBeaconManager.start: already running")
            return
        }
        print("MockBeaconManager.start")
        isRunning = true
        t = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.t += 1.0

            let uuid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
            let phase = Int(self.t)

            let rssi1: Int
            let rssi2: Int

            switch phase {
            case 0..<10:
                // Near N1
                rssi1 = -60
                rssi2 = -75
            case 10..<20:
                // Near N2
                rssi1 = -70
                rssi2 = -70
            default:
                // Near E1
                rssi1 = -80
                rssi2 = -65
            }

            print("Mock phase \(phase): rssi1=\(rssi1), rssi2=\(rssi2)")

            self.latest = [
                BeaconReading(id: "\(uuid):1:1", rssi: rssi1, ts: Date()),
                BeaconReading(id: "\(uuid):1:2", rssi: rssi2, ts: Date())
            ]
        }
    }

    func stop() {
        guard isRunning else {
            print("MockBeaconManager.stop: not running")
            return
        }
        print("MockBeaconManager.stop")
        timer?.invalidate()
        timer = nil
        isRunning = false
        latest = []
    }
}
