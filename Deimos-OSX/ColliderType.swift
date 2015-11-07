import SpriteKit
import GameplayKit

enum ColliderType: Int {
    case Obstacle = 1
    case Player = 2
    case AI = 4

    func shouldNotifyOnContactWithColliderType(colliderType: ColliderType) -> Bool {
        return self != .Obstacle
    }

    var collisionBitMask: UInt32 {
        if self == .Obstacle {
            return 6
        } else {
            return 0
        }
    }
}

protocol ContactNotifiable {
    func contactWithEntityBegan(entity: GKEntity)
    func contactWithEntitedEnded(entity: GKEntity)
}