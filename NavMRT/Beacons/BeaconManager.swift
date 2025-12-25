import Foundation
import CoreLocation
import Combine

final class BeaconManager: NSObject, ObservableObject {
    @Published var latest: [BeaconReading] = []

    private let locationManager = CLLocationManager()
    private var constraints: [CLBeaconIdentityConstraint] = []
    private var isRanging = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func configure(beacons registry: BeaconRegistry) {
        constraints = registry.beacons.compactMap { b in
            guard let uuid = UUID(uuidString: b.uuid) else {
                print("Invalid UUID in beacons.json for id=\(b.id): \(b.uuid)")
                return nil
            }
            return CLBeaconIdentityConstraint(
                uuid: uuid,
                major: CLBeaconMajorValue(b.major),
                minor: CLBeaconMinorValue(b.minor)
            )
        }
    }


    func start() {
        guard !isRanging else { return }
        isRanging = true

        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        for c in constraints {
            locationManager.startRangingBeacons(satisfying: c)
        }
    }

    func stop() {
        guard isRanging else { return }
        isRanging = false
        for c in constraints {
            locationManager.stopRangingBeacons(satisfying: c)
        }
        latest = []
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location auth:", manager.authorizationStatus.rawValue)
    }

    func locationManager(_ manager: CLLocationManager,
                         didRange beacons: [CLBeacon],
                         satisfying constraint: CLBeaconIdentityConstraint) {
        latest = beacons
            .filter { $0.rssi != 0 } // 0 means invalid reading
            .map { BeaconReading(from: $0) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Beacon ranging error:", error.localizedDescription)
    }
}
