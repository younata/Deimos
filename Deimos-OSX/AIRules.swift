import GameplayKit

enum Fact: String {
    case PlayerNear = "PlayerNear"
    case PlayerMeh = "PlayerMeh"
    case PlayerFar = "PlayerFar"
}

class FuzzyAIRule: GKRule {
    var snapshot: EntitySnapshot!

    let fact: Fact

    func grade() -> Float { return 0.0 }

    init(fact: Fact) {
        self.fact = fact
    }

    override func evaluatePredicateWithSystem(system: GKRuleSystem) -> Bool {
        snapshot = system.state["snapshot"] as? EntitySnapshot

        if grade() >= 0.0 {
            return true
        }

        return false
    }

    override func performActionWithSystem(system: GKRuleSystem) {
        system.assertFact(fact.rawValue, grade: grade())
    }
}

class PlayerNearRule: FuzzyAIRule {
    override func grade() -> Float {
        guard let distance = snapshot.playerTarget?.distance else { return 0 }
        let oneThird = Configuration.proximityFactor / 3
        return Float((oneThird - distance) / oneThird)
    }

    init() { super.init(fact: .PlayerNear) }
}

class PlayerMehRule: FuzzyAIRule {
    override func grade() -> Float {
        guard let distance = snapshot.playerTarget?.distance else { return 0 }
        let oneThird = Configuration.proximityFactor / 3
        return Float(1 - (fabs(distance - oneThird) / oneThird))
    }

    init() { super.init(fact: .PlayerMeh) }
}

class PlayerFarRule: FuzzyAIRule {
    override func grade() -> Float {
        guard let distance = snapshot.playerTarget?.distance else { return 0 }
        let oneThird = Configuration.proximityFactor / 3
        return Float((distance - oneThird) / oneThird)
    }

    init() { super.init(fact: .PlayerFar) }
}