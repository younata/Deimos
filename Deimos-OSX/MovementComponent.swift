import GameplayKit

struct MovementKind {
    let displacement: CGVector

    init(_ displacement: CGVector) {
        self.displacement = displacement
    }
}

class MovementComponent: GKComponent {

    var nextMovement: MovementKind?

    let maximumSteering = CGFloat(M_2_PI / 64)

    var positionComponent: PositionComponent? {
        return self.entity?.componentForClass(PositionComponent.self)
    }

    var physicsComponent: PhysicsComponent? {
        return self.entity?.componentForClass(PhysicsComponent.self)
    }

    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)

        guard let positionComponent = self.positionComponent, movement = nextMovement else { return }

        let steering = -movement.displacement.dx * maximumSteering

        let speedMultiplier: CGFloat = 150

        let forwardSpeed = movement.displacement.dy
        let angularSpeed = movement.displacement.dy * sin(steering) * speedMultiplier

        positionComponent.rotation += angularSpeed * CGFloat(seconds)
        let rotation = positionComponent.rotation

        let velocity = CGVector(dx: forwardSpeed * sin(-rotation), dy: forwardSpeed * cos(-rotation)) * speedMultiplier

        positionComponent.position += CGPoint(velocity * CGFloat(seconds))
    }
}
