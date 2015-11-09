import GameplayKit
import SpriteKit

private enum Side: Int {
    case Top = 0
    case Bottom = 1
    case Left = 2
    case Right = 3

    var oppositeSide: Side {
        switch self {
        case .Top: return .Bottom
        case .Bottom: return .Top
        case .Left: return .Right
        case .Right: return .Left
        }
    }

    static let allSides: [Side] = [.Top, .Bottom, .Left, .Right]
}

class MazeNode: SKShapeNode {
    private var walls: [Side: SKShapeNode] = [:]

    private var numberOfSides: Int { return walls.count }

    private class func MazeNodeFromSides(sides: Set<Side> = [.Top, .Bottom, .Left, .Right]) -> MazeNode {
        let sizeLength = Configuration.MazeSideLength
        let size = CGSize(width: sizeLength, height: sizeLength)
        let node = MazeNode(rectOfSize: size)

        node.fillColor = Configuration.MazeFloorColor
        node.strokeColor = Configuration.MazeFloorColor

        for side in sides {
            node.addWallForSide(side)
        }
        return node
    }

    private func addWallForSide(side: Side) {
        guard self.walls[side] == nil else { return }

        let p1: CGPoint
        let p2: CGPoint

        let sideLength = Configuration.MazeSideLength

        switch (side) {
        case .Top: (p1, p2) = (CGPoint(x: 0, y: sideLength), CGPoint(x: sideLength, y: sideLength))
        case .Bottom: (p1, p2) = (CGPoint(x: 0, y: 0), CGPoint(x: sideLength, y: 0))
        case .Left: (p1, p2) = (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: sideLength))
        case .Right: (p1, p2) = (CGPoint(x: sideLength, y: 0), CGPoint(x: sideLength, y: sideLength))
        }

        let points = [p1, p2]

        let node = SKShapeNode(points: UnsafeMutablePointer<CGPoint>(points), count: 2)
        node.name = "Obstacle"
        node.physicsBody = SKPhysicsBody(edgeFromPoint: p1, toPoint: p2)
        node.strokeColor = Configuration.MazeWallColor
        node.fillColor = node.strokeColor
        addChild(node)

        self.walls[side] = node
    }

    private func removeWallForSide(side: Side) {
        if let wall = walls.removeValueForKey(side) {
            wall.removeFromParent()
        }
    }
}

extension GKRandom {
    func randomPair(maxes: (Int, Int)) -> OrderedPair {
        return OrderedPair(x: nextIntWithUpperBound(maxes.0), y: nextIntWithUpperBound(maxes.1))
    }

    private func randomSide(excluding: [Side] = []) -> Side? {
        if excluding.isEmpty {
            return Side(rawValue: nextIntWithUpperBound(4))
        } else {
            let numbers = Array(Set(Side.allSides).subtract(Set(excluding)))
            if numbers.isEmpty { return nil }
            return numbers[nextIntWithUpperBound(numbers.count)]
        }
    }
}

struct OrderedPair: Equatable {
    let x: Int
    let y: Int
}

func ==(a: OrderedPair, b: OrderedPair) -> Bool {
    return a.x == b.x && a.y == b.y
}

class MazeGenerator {
    private var nodes = [MazeNode]()

    let generatedNode = SKNode()

    init(size: (x: Int, y: Int)) {
        assert(size.x > 0 && size.y > 0)

        let sideLength = Configuration.MazeSideLength

        var rows = [[MazeNode]]()

        for x in 0..<size.x {
            var column = [MazeNode]()
            for y in 0..<size.y {
                let node = MazeNode.MazeNodeFromSides()
                node.position = CGPoint(x: CGFloat(x) * sideLength, y: CGFloat(y) * sideLength)
                self.nodes.append(node)
                column.append(node)
            }
            rows.append(column)
        }

        let randomGenerator = GKARC4RandomSource()

        let maxRowLength = rows.count - 1
        let maxColumnLength = rows[0].count - 1

        var pair = randomGenerator.randomPair(size)
        var visited = [pair]
        var stack: [OrderedPair] = []

        // helper functions
        let hasNodeOnOppositeEdge: (OrderedPair, Side) -> Bool = {location, side in
            switch side {
            case .Top: return location.y < maxColumnLength
            case .Bottom: return location.y > 0
            case .Right: return location.x < maxRowLength
            case .Left: return location.x > 0
            }
        }

        let nextLocationForSide: (OrderedPair, Side) -> OrderedPair = {location, side in
            let nextLocation: OrderedPair
            switch side {
            case .Top:
                nextLocation = OrderedPair(x: location.x, y: location.y + 1)
            case .Bottom:
                nextLocation = OrderedPair(x: location.x, y: location.y - 1)
            case .Left:
                nextLocation = OrderedPair(x: location.x - 1, y: location.y)
            case .Right:
                nextLocation = OrderedPair(x: location.x + 1, y: location.y)
            }
            return nextLocation
        }

        let hasUnvisitedNodeOnOppositeEdge: (OrderedPair, Side) -> Bool = {location, side in
            guard hasNodeOnOppositeEdge(location, side) else { return false }

            return !visited.contains(nextLocationForSide(location, side))
        }

        let knockOutWallOfCell: (location: OrderedPair) -> OrderedPair? = {location in
            let cell = rows[location.x][location.y]

            var shouldContinue = false

            for side in Side.allSides {
                if hasUnvisitedNodeOnOppositeEdge(location, side) {
                    shouldContinue = true
                    break
                }
            }

            guard shouldContinue else { return nil }

            var triedSides = [Side]()
            var nextSide: Side

            repeat {
                guard let triedSide = randomGenerator.randomSide(triedSides) else { return nil }
                nextSide = triedSide
                triedSides.append(nextSide)
            } while !hasUnvisitedNodeOnOppositeEdge(location, nextSide)

            let nextLocation = nextLocationForSide(location, nextSide)

            cell.removeWallForSide(nextSide)
            let nextCell = rows[nextLocation.x][nextLocation.y]
            nextCell.removeWallForSide(nextSide.oppositeSide)

            return nextLocation
        }

        while visited.count < nodes.count {
            if let nextPair = knockOutWallOfCell(location: pair) {
                stack.append(pair)
                visited.append(nextPair)
                pair = nextPair
            } else if let previousPair = stack.popLast() {
                pair = previousPair
            } else {
                break
            }
        }

        for node in nodes {
            generatedNode.addChild(node)
        }
    }
}