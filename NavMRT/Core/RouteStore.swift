import Foundation
import Combine

struct RoutePair: Codable, Equatable, Hashable, Identifiable {
    let startId: String
    let goalId: String
    var id: String { "\(startId)->\(goalId)" }
}

final class RouteStore: ObservableObject {
    static let shared = RouteStore()

    @Published private(set) var favorites: [RoutePair] = []
    @Published private(set) var recents: [RoutePair] = []

    private let favKey = "navmrt.favorites.v1"
    private let recKey = "navmrt.recents.v1"
    private let maxRecents = 8

    private init() {
        favorites = load(key: favKey)
        recents   = load(key: recKey)
    }

    func isFavorite(_ r: RoutePair) -> Bool {
        favorites.contains(r)
    }

    func toggleFavorite(_ r: RoutePair) {
        if let idx = favorites.firstIndex(of: r) {
            favorites.remove(at: idx)
        } else {
            favorites.insert(r, at: 0)
        }
        save(favorites, key: favKey)
    }

    func recordRecent(_ r: RoutePair) {
        // Don’t record start==goal
        guard r.startId != r.goalId else { return }

        recents.removeAll { $0 == r }
        recents.insert(r, at: 0)
        if recents.count > maxRecents { recents = Array(recents.prefix(maxRecents)) }
        save(recents, key: recKey)
    }

    func clearRecents() {
        recents = []
        save(recents, key: recKey)
    }

    // MARK: - Persistence

    private func load(key: String) -> [RoutePair] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([RoutePair].self, from: data)) ?? []
    }

    private func save(_ value: [RoutePair], key: String) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
}
