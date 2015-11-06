import GameplayKit

protocol RulesComponentDelegate: class {
    func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
}

class RulesComponent: GKComponent {
    weak var delegate: RulesComponentDelegate?

    var ruleSystem = GKRuleSystem()

    private var timeSinceRulesUpdate: NSTimeInterval = 0.0

    init(rules: [GKRule]) {
        ruleSystem.addRulesFromArray(rules)
    }

    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)

        timeSinceRulesUpdate += seconds

        if timeSinceRulesUpdate < 1 { return }

        timeSinceRulesUpdate = 0

        if let ai = entity as? AIPerson,
            map = ai.componentForClass(RenderComponent)?.node.scene as? MapScene,
            entitySnapshot = MapSnapshot(scene: map).entitySnapshots[ai] {

                ruleSystem.reset()
                ruleSystem.state["snapshot"] = entitySnapshot
                ruleSystem.evaluate()

                delegate?.rulesComponent(self, didFinishEvaluatingRuleSystem: ruleSystem)
        }
    }
}