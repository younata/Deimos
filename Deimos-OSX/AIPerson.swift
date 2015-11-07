import CoreGraphics
import GameplayKit
import SpriteKit

class AIPerson: GKEntity, GKAgentDelegate, RulesComponentDelegate {
    enum Mandate {
        case patrol
        case standAtPoint(CGPoint)
    }

    var mandate: Mandate {
        didSet {
            self.agent.behavior = behaviorForMandate
        }
    }

    var patrolPoints = [CGPoint]()

    lazy var agent: GKAgent2D = {
        let agent = GKAgent2D()
        self.addComponent(agent)
        return agent
    }()

    var behaviorForMandate: GKBehavior {
        guard let mapScene = componentForClass(RenderComponent.self)?.node.scene as? MapScene else {
            return GKBehavior()
        }
        let behavior: GKBehavior

        let debugPoints: [CGPoint]

        switch mandate {
        case .patrol:
            debugPoints = patrolPoints
            behavior = AIBehavior.behaviorForAgent(agent, patrollingPathWithPoints: patrolPoints, pathRadius: 20, inScene: mapScene)
        case let .standAtPoint(position):
            debugPoints = []
            behavior = AIBehavior.behaviorForAgent(agent, returnToPoint: position, radius: 20, inScene: mapScene)
        }

        drawDebugPath(debugPoints, cycle: true, color: SKColor.greenColor(), radius: 20)

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

    let debugNode = SKNode()

    private func configurePerson() {
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
        let color = SKColor.grayColor()
        triangle.strokeColor = color

        let circle = SKShapeNode(circleOfRadius: radius)
        circle.strokeColor = color
        triangle.addChild(circle)

        let render = RenderComponent(node: triangle)

        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        render.node.physicsBody = physicsBody
        let physics = PhysicsComponent(physicsBody: physicsBody, colliderType: .AI)

        agent.delegate = self
        agent.maxSpeed = 150
        agent.maxAcceleration = 250
        agent.mass = 0.5
        agent.radius = Float(radius)

        let rules = RulesComponent(rules: [
            PlayerNearRule(),
            PlayerMehRule(),
            PlayerFarRule(),
            ])
        rules.delegate = self

        for component in [movement, position, render, physics, agent] {
            addComponent(component)
        }
    }

    func drawDebugPath(path: [CGPoint], cycle: Bool, color: SKColor, radius: Float) {
        guard path.count > 1 else { return }

        debugNode.removeAllChildren()

        var drawPath = path

        if cycle {
            drawPath += [drawPath.first!]
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // Use RGB component accessor common between `UIColor` and `NSColor`.
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.4)
        let fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.2)

        for index in 0..<drawPath.count - 1 {
            let current = CGPoint(x: drawPath[index].x, y: drawPath[index].y)
            let next = CGPoint(x: drawPath[index + 1].x, y: drawPath[index + 1].y)

            let circleNode = SKShapeNode(circleOfRadius: CGFloat(radius))
            circleNode.strokeColor = strokeColor
            circleNode.fillColor = fillColor
            circleNode.position = current
            debugNode.addChild(circleNode)

            let deltaX = next.x - current.x
            let deltaY = next.y - current.y
            let rectNode = SKShapeNode(rectOfSize: CGSize(width: hypot(deltaX, deltaY), height: CGFloat(radius) * 2))
            rectNode.strokeColor = strokeColor
            rectNode.fillColor = fillColor
            rectNode.zRotation = atan(deltaY / deltaX)
            rectNode.position = CGPoint(x: current.x + (deltaX / 2.0), y: current.y + (deltaY / 2.0))
            debugNode.addChild(rectNode)
        }
    }

    // MARK: GKAgentDelegate

    func agentWillUpdate(_: GKAgent) {
        // update agent position/rotation
        guard let position = self.componentForClass(PositionComponent.self) else { return }
        agent.position = float2(position.position)
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

    // MARK: RulesComponentDelegate

    func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem) {
        let playerNear = ruleSystem.minimumGradeForFacts([Fact.PlayerNear.rawValue])
        let playerDistant = ruleSystem.minimumGradeForFacts([Fact.PlayerFar.rawValue, Fact.PlayerMeh.rawValue])

        if playerNear > playerDistant {
            switch mandate {
            case .standAtPoint(_): break
            default:
                guard let position = self.componentForClass(PositionComponent.self) else { return }
                mandate = .standAtPoint(position.position)
                break
            }
        } else {
            switch mandate {
            case .patrol: break
            default:
                mandate = .patrol
            }
        }
    }
}