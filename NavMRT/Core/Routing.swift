import Foundation

struct GraphRouter {

    static func buildAdjacency(from graph: Graph) -> [String: [(neighbor: String, cost: Double)]] {
        var adj: [String: [(String, Double)]] = [:]

        for edge in graph.edges {
            adj[edge.from, default: []].append((edge.to, edge.len))
            adj[edge.to, default: []].append((edge.from, edge.len)) // undirected
        }

        return adj
    }

    static func shortestPath(
        from startId: String,
        to goalId: String,
        in graph: Graph
    ) -> [Graph.Node] {
        let adj = buildAdjacency(from: graph)

        var dist: [String: Double] = [:]
        var prev: [String: String] = [:]
        var unvisited = Set(graph.nodes.map { $0.id })

        for node in unvisited {
            dist[node] = Double.greatestFiniteMagnitude
        }
        dist[startId] = 0

        func nearestUnvisited() -> String? {
            unvisited.min { (a, b) in
                (dist[a] ?? .greatestFiniteMagnitude) <
                (dist[b] ?? .greatestFiniteMagnitude)
            }
        }

        while let current = nearestUnvisited() {
            unvisited.remove(current)
            if current == goalId { break }

            guard let neighbors = adj[current] else { continue }

            let currentDist = dist[current] ?? .greatestFiniteMagnitude

            for (n, cost) in neighbors {
                let alt = currentDist + cost
                if alt < (dist[n] ?? .greatestFiniteMagnitude) {
                    dist[n] = alt
                    prev[n] = current
                }
            }
        }

        // Reconstruct path
        guard dist[goalId] != nil, dist[goalId] != .greatestFiniteMagnitude else {
            return []
        }

        var pathIds: [String] = []
        var u: String? = goalId

        while let nodeId = u {
            pathIds.append(nodeId)
            u = prev[nodeId]
        }

        pathIds.reverse()

        // Map IDs back to nodes
        let nodeMap = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        return pathIds.compactMap { nodeMap[$0] }
    }

    static func nearestNode(
        toX x: Double,
        y: Double,
        floor: String,
        in graph: Graph
    ) -> Graph.Node? {
        var best: Graph.Node?
        var bestDist = Double.greatestFiniteMagnitude

        for node in graph.nodes where node.floor == floor {
            let dx = node.x - x
            let dy = node.y - y
            let d2 = dx*dx + dy*dy
            if d2 < bestDist {
                bestDist = d2
                best = node
            }
        }
        return best
    }
}

