import CoreGraphics
import GameplayKit
import SpriteKit

class AIPerson: GKEntity, GKAgentDelegate {
    enum Mandate {
        case patrol
        case standAtPoint(CGPoint)
    }

    var mandate: Mandate

    var patrolPoints = [CGPoint]()

    var agent: GKAgent2D {
        guard let agent = componentForClass(GKAgent2D.self) else { fatalError("What are you doing, you EDJIT!?") }
        return agent
    }

    var behaviorForMandate: GKBehavior {
        guard let mapScene = componentForClass(RenderComponent.self)?.node.scene as? MapScene else {
            return GKBehavior()
        }
        let behavior: GKBehavior

        switch mandate {
        case .patrol:
            behavior = AIBehavior.behaviorForAgent(agent, patrollingPathWithPoints: patrolPoints, pathRadius: 10, inScene: mapScene)
        case let .standAtPoint(position):
            behavior = AIBehavior.behaviorForAgent(agent, returnToPoint: position, radius: 10, inScene: mapScene)
        }

        return behavior
    }

    required init(patrolPoints: [CGPoint]) {
        self.patrolPoints = patrolPoints
        self.mandate = .patrol
        super.init()

        configurePerson()
    }

    required init(stand: CGPoint) {
        self.mandate = .standAtPoint(stand)
        super.init()

        configurePerson()
    }

    private func configurePerson() {
        let movement = MovementComponent()
        let position = PositionComponent()

        let node = SKLabelNode(text: "M")
        node.fontColor = NSColor.blackColor()
        let render = RenderComponent(node: node)

        let physicsBody = SKPhysicsBody()
        render.node.physicsBody = physicsBody
        let physics = PhysicsComponent(physicsBody: physicsBody)

        for component in [movement, position, render, physics] {
            addComponent(component)
        }

        let agent = GKAgent2D()

        agent.delegate = self
        agent.maxSpeed = 150
        agent.maxAcceleration = 250
        agent.mass = 0.5
        agent.radius = 20

        addComponent(agent)

        agent.behavior = behaviorForMandate
    }

    func agentWillUpdate(_: GKAgent) {
        // update agent position/rotation
        guard let position = self.componentForClass(PositionComponent.self) else { return }
        agent.position = float2(position.position)
//        agent.rotation = Float(position.rotation)
    }

    func agentDidUpdate(_: GKAgent) {
        guard let positionComponent = self.componentForClass(PositionComponent.self) else { return }
        positionComponent.position = CGPoint(agent.position)
        let velocity = CGVector(agent.velocity).normalize
        if velocity != CGVector.zero {
            positionComponent.rotation = atan2(-velocity.dx, velocity.dy)
        } else {
            positionComponent.rotation = CGFloat(agent.rotation)
        }
    }
}