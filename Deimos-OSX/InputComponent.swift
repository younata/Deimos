import GameplayKit

class InputComponent: GKComponent {
    struct InputState {
        var movement: MovementKind?

        static let noInput = InputState()
    }

    var inputState = InputState() {
        didSet {
            applyInputState(inputState)
        }
    }

    func applyInputState(state: InputState) {
        if let movementComponent = entity?.componentForClass(MovementComponent.self) {
            movementComponent.nextMovement = inputState.movement
        }
    }
}

extension InputComponent: ControlInputSourceDelegate {
    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateWithMovement movementVelocity: CGVector) {
        inputState.movement = MovementKind(movementVelocity)
    }

    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateRunning running: Bool) {}

    func controlInputSourceDidSelect(controlInputSource: ControlInputSourceType) {}
}
