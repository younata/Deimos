import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
    let physicsBody: SKPhysicsBody

    init(physicsBody: SKPhysicsBody) {
        self.physicsBody = physicsBody
        self.physicsBody.dynamic = false

        super.init()
    }
}
