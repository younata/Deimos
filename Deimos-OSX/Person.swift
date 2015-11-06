import SpriteKit
import GameplayKit

final class Person: GKEntity {

    let agent: GKAgent2D

    override init() {
        self.agent = GKAgent2D()

        super.init()

        let movement = MovementComponent()
        let position = PositionComponent()

        let node = SKLabelNode(text: "A")
        node.fontColor = NSColor.blackColor()
        let render = RenderComponent(node: node)

        let physicsBody = SKPhysicsBody()
        render.node.physicsBody = physicsBody
        let physics = PhysicsComponent(physicsBody: physicsBody)

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