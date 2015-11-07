import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
    let physicsBody: SKPhysicsBody

    init(physicsBody: SKPhysicsBody, colliderType: ColliderType) {
        self.physicsBody = physicsBody
        self.physicsBody.categoryBitMask = UInt32(colliderType.rawValue)
        self.physicsBody.collisionBitMask = colliderType.collisionBitMask
        self.physicsBody.dynamic = false

        super.init()
    }
}
