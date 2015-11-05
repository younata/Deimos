import SpriteKit
import GameplayKit

final class Person: GKEntity {
    override init() {
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
}