import SpriteKit
import GameplayKit

class MapScene: SKScene, SKPhysicsContactDelegate {
    lazy var person: Person = {
        return Person()
    }()

    var npcs = [AIPerson]()

    var entities: [GKEntity] {
        return [person] + npcs
    }

    let inputSource = KeyboardControlInputSource()

    // MARK: Pathfinding

    let graph = GKObstacleGraph(obstacles: [], bufferRadius: Float(Configuration.unitRadius))

    lazy var obstacleNodes: [SKNode] = []

    lazy var polygonObstacles: [GKPolygonObstacle] = SKNode.obstaclesFromNodePhysicsBodies(self.obstacleNodes)

    // MARK: Pathfinding Debug

    var graphLayer = SKNode()
    var debugObstacleLayer = SKNode()

    // blah

    func mapBoundsNode() -> SKNode {
        let node = SKNode()

        node.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        node.name = "obstacle"

        return node
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        let maze = MazeGenerator(size: (x: 10, y: 10))
        self.addChild(maze.generatedNode)

        person.componentForClass(PositionComponent.self)?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        if let node = person.componentForClass(RenderComponent.self)?.node {
            self.addChild(node)
        }

        self.addChild(self.graphLayer)
        self.graph.addObstacles(self.polygonObstacles)
        self.drawDebugGraph()

        if let input = person.componentForClass(InputComponent.self) {
            inputSource.delegate = input
        }
    }

    override func keyDown(event: NSEvent) {
        guard let characters = event.characters?.characters else { return }
        for char in characters {
            inputSource.keyDown(char)
        }
    }

    override func keyUp(event: NSEvent) {
        guard let characters = event.characters?.characters else { return }
        for char in characters {
            inputSource.keyUp(char)
        }
    }

    var lastUpdateTimeInterval: CFTimeInterval = 0
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        guard lastUpdateTimeInterval > 0 else {
            lastUpdateTimeInterval = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        for person in self.entities {
            person.updateWithDeltaTime(deltaTime)
        }
    }

    func didBeginContact(contact: SKPhysicsContact) {
    }

    func didEndContact(contact: SKPhysicsContact) {
    }

    private func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiable, GKEntity) -> Void) {
        guard let colliderA = ColliderType(rawValue: Int(contact.bodyA.categoryBitMask)),
            colliderB = ColliderType(rawValue: Int(contact.bodyB.categoryBitMask)) else {
                return
        }

        let shouldCallABack = colliderA.shouldNotifyOnContactWithColliderType(colliderB)
        let shouldCallBBack = colliderB.shouldNotifyOnContactWithColliderType(colliderA)
    }
}

extension MapScene {
    func drawDebugGraph() {
        for node in graph.nodes as! [GKGraphNode2D] {
            for destination in node.connectedNodes as! [GKGraphNode2D] {
                let points = [CGPoint(node.position), CGPoint(destination.position)]

                let shapeNode = SKShapeNode(points: UnsafeMutablePointer<CGPoint>(points), count: 2)
                shapeNode.strokeColor = SKColor(white: 0.0, alpha: 0.1)
                shapeNode.lineWidth = 2.0
                shapeNode.zPosition = -1
                graphLayer.addChild(shapeNode)
            }
        }
    }
}
