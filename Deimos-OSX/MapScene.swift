import SpriteKit
import GameplayKit

class MapScene: SKScene {
    lazy var person: Person = {
        return Person()
    }()

    var npcs = [AIPerson]()

    var entities: [GKEntity] {
        return [person] + npcs
    }

    let inputSource = KeyboardControlInputSource()

    var polygonObstacles: [GKPolygonObstacle] {
        return SKNode.obstaclesFromNodePhysicsBodies(self["obstacles"])
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        person.componentForClass(PositionComponent.self)?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        if let node = person.componentForClass(RenderComponent.self)?.node {
            self.addChild(node)
        }

        for i in 0..<1 {
            let person: AIPerson
            if i % 2 == 0 {
                let width = size.width
                let height = size.height
                let points = [CGPoint(x: 20, y: 20), CGPoint(x: width - 20, y: 20), CGPoint(x: width - 20, y: height - 20), CGPoint(x: 20, y: height - 20)]
                person = AIPerson(patrolPoints: points)
            } else {
                person = AIPerson(stand: CGPoint(x: 20, y: 20))
            }
            if let node = person.componentForClass(RenderComponent.self)?.node {
                self.addChild(node)
            }
            person.agent.behavior = person.behaviorForMandate
            npcs.append(person)
        }

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
}
