import SwiftUI

struct RSSIConsoleView: View {
    @StateObject var bm = MockBeaconManager()
    let ema = RSSIEMA()

    var body: some View {
        List(bm.latest) { b in
            let smoothed = ema.update(id: b.id, rssi: b.rssi)
            Text("\(b.identifierShort)  RSSI: \(b.rssi)  EMA: \(String(format: "%.1f", smoothed))")
                .monospaced()
        }
        .onAppear { bm.start() }
        .onDisappear { bm.stop() }
        .navigationTitle("RSSI Console")
    }
}
