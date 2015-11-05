import GameplayKit

struct MovementKind {
    let running: Bool

    let displacement: CGVector

    init(_ displacement: CGVector, running: Bool = false) {
        self.displacement = displacement
        self.running = running
    }
}

class MovementComponent: GKComponent {

    var nextMovement: MovementKind?

    private let speedMultiplier: CGFloat = 150 // points/second

    var positionComponent: PositionComponent? {
        return self.entity?.componentForClass(PositionComponent.self)
    }

    var physicsComponent: PhysicsComponent? {
        return self.entity?.componentForClass(PhysicsComponent.self)
    }

    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)

        guard let positionComponent = self.positionComponent, movement = nextMovement else { return }

        let movementSpeed = speedMultiplier * (movement.running ? 2 : 1)

        let velocity = movement.displacement.normalize * movementSpeed

        positionComponent.position += CGPoint(velocity * CGFloat(seconds))
        if velocity != CGVector.zero {
            positionComponent.rotation = atan2(-velocity.dx, velocity.dy)
        }
    }
}
