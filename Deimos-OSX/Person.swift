import SpriteKit
import GameplayKit

final class Person: GKEntity {

    let agent: GKAgent2D

    override init() {
        self.agent = GKAgent2D()

        super.init()

        let movement = MovementComponent()
        let position = PositionComponent()

        let radius = Configuration.unitRadius

        let trianglePath = CGPathCreateMutable()
        CGPathMoveToPoint(trianglePath, nil, 0, radius)
        let x = radius * (2.0 / 3.0)
        let y = -radius * (2.0 / 3.0)
        CGPathAddLineToPoint(trianglePath, nil, x, y)
        CGPathAddLineToPoint(trianglePath, nil, -x, y)
        CGPathAddLineToPoint(trianglePath, nil, 0, radius)
        let triangle = SKShapeNode(path: trianglePath)
        let color = SKColor.blackColor()
        triangle.strokeColor = color

        let circle = SKShapeNode(circleOfRadius: radius)
        circle.strokeColor = color
        triangle.addChild(circle)

        let render = RenderComponent(node: triangle)

        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        render.node.physicsBody = physicsBody
        let physics = PhysicsComponent(physicsBody: physicsBody, colliderType: .Player)

        let input = InputComponent()

        for component in [movement, position, render, physics, input] {
            self.addComponent(component)
        }
    }

    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        guard let positionComponent = self.componentForClass(PositionComponent.self) else { return }

        self.agent.position = float2(positionComponent.position)
    }
}