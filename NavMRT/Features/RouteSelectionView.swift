import SwiftUI

struct RouteSelectionView: View {
    private let graph = DataStore.shared.graph
    private let places = DataStore.shared.places

    @StateObject private var store = RouteStore.shared

    @State private var startId: String = ""
    @State private var goalId: String = ""

    private var startOptions: [Graph.Node] {
        graph.nodes.filter { places[$0.id]?.startAllowed ?? false }
    }

    private var destOptions: [Graph.Node] {
        graph.nodes.filter { places[$0.id]?.destAllowed ?? false }
    }

    private var startByCategory: [(category: String, nodes: [Graph.Node])] { groupByCategory(startOptions) }
    private var destByCategory: [(category: String, nodes: [Graph.Node])] { groupByCategory(destOptions) }

    private var currentRoute: RoutePair {
        RoutePair(startId: startId, goalId: goalId)
    }

    private var canStart: Bool {
        !startId.isEmpty && !goalId.isEmpty && startId != goalId
    }

    var body: some View {
        Form {

            if !store.favorites.isEmpty {
                Section("Favorites") {
                    ForEach(store.favorites) { r in
                        NavigationLink {
                            NavigatorView(startId: r.startId, goalId: r.goalId)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routeTitle(r))
                                Text(routeSubtitle(r))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if !store.recents.isEmpty {
                Section {
                    ForEach(store.recents) { r in
                        NavigationLink {
                            NavigatorView(startId: r.startId, goalId: r.goalId)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routeTitle(r))
                                Text(routeSubtitle(r))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button(role: .destructive) {
                        store.clearRecents()
                    } label: {
                        Text("Clear recents")
                    }
                } header: {
                    Text("Recent")
                }
            }

            Section("From") {
                Picker("Start", selection: $startId) {
                    Text("Select start").tag("")
                    ForEach(startByCategory, id: \.category) { section in
                        Section(header: Text(sectionTitle(section.category))) {
                            ForEach(section.nodes, id: \.id) { n in
                                Text(displayName(for: n)).tag(n.id)
                            }
                        }
                    }
                }
                .pickerStyle(.navigationLink)
            }

            Section("To") {
                Picker("Destination", selection: $goalId) {
                    Text("Select destination").tag("")
                    ForEach(destByCategory, id: \.category) { section in
                        Section(header: Text(sectionTitle(section.category))) {
                            ForEach(section.nodes, id: \.id) { n in
                                Text(displayName(for: n)).tag(n.id)
                            }
                        }
                    }
                }
                .pickerStyle(.navigationLink)
            }

            Section {
                NavigationLink {
                    NavigatorView(startId: startId, goalId: goalId)
                } label: {
                    Text("Start guided navigation")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!canStart)

                Button {
                    guard canStart else { return }
                    store.toggleFavorite(currentRoute)
                } label: {
                    Text(store.isFavorite(currentRoute) ? "Remove from favorites" : "Add to favorites")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!canStart)
            }
        }
        .navigationTitle("Route Selection")
        .onAppear {
            // Defaults: first available items
            if startId.isEmpty, let first = startOptions.sorted(by: sortNodes).first?.id { startId = first }
            if goalId.isEmpty, let first = destOptions.sorted(by: sortNodes).first?.id { goalId = first }

            // Ensure defaults aren't the same
            if startId == goalId,
               let alt = destOptions.sorted(by: sortNodes).first(where: { $0.id != startId }) {
                goalId = alt.id
            }
        }
        .onChange(of: startId) { _, newValue in
            if newValue == goalId,
               let alt = destOptions.sorted(by: sortNodes).first(where: { $0.id != newValue }) {
                goalId = alt.id
            }
        }
        .onChange(of: goalId) { _, newValue in
            if newValue == startId,
               let alt = startOptions.sorted(by: sortNodes).first(where: { $0.id != newValue }) {
                startId = alt.id
            }
        }
    }

    // MARK: - Labels

    private func nodeName(_ id: String) -> String {
        places[id]?.name ?? id
    }

    private func nodeCategory(_ id: String) -> String {
        places[id]?.category ?? "place"
    }

    private func nodeFloor(_ id: String) -> String {
        graph.nodes.first(where: { $0.id == id })?.floor ?? ""
    }

    private func routeTitle(_ r: RoutePair) -> String {
        "\(nodeName(r.startId)) → \(nodeName(r.goalId))"
    }

    private func routeSubtitle(_ r: RoutePair) -> String {
        "\(nodeCategory(r.startId)) (\(nodeFloor(r.startId))) → \(nodeCategory(r.goalId)) (\(nodeFloor(r.goalId)))"
    }

    // MARK: - Grouping

    private func groupByCategory(_ nodes: [Graph.Node]) -> [(category: String, nodes: [Graph.Node])] {
        let grouped = Dictionary(grouping: nodes) { node in
            places[node.id]?.category ?? "other"
        }
        let cats = grouped.keys.sorted { categoryRank($0) < categoryRank($1) || (categoryRank($0) == categoryRank($1) && $0 < $1) }
        return cats.map { cat in
            let ns = (grouped[cat] ?? []).sorted(by: sortNodes)
            return (cat, ns)
        }
    }

    private func sortNodes(_ a: Graph.Node, _ b: Graph.Node) -> Bool {
        displayName(for: a) < displayName(for: b)
    }

    private func displayName(for n: Graph.Node) -> String {
        let info = places[n.id]
        let name = info?.name ?? n.id
        let cat  = info?.category ?? "place"
        return "\(name) (\(cat), \(n.floor))"
    }

    private func sectionTitle(_ category: String) -> String {
        switch category.lowercased() {
        case "entrance": return "Entrances"
        case "elevator": return "Elevators"
        case "gate":     return "Ticket gates"
        case "platform": return "Platforms"
        case "toilet":   return "Restrooms"
        case "junction": return "Junctions"
        default:         return category.capitalized
        }
    }

    private func categoryRank(_ category: String) -> Int {
        switch category.lowercased() {
        case "entrance": return 0
        case "gate":     return 1
        case "elevator": return 2
        case "platform": return 3
        case "toilet":   return 4
        case "junction": return 9
        default:         return 50
        }
    }
}
