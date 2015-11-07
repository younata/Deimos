import GameplayKit

enum ControlInputDirection: Int {
    case Up = 0, Down, Left, Right

    init?(vector: CGVector) {
        // Require sufficient displacement to specify direction.
        guard vector.length >= 0.5 else { return nil }

        // Take the max displacement as the specified axis.
        if abs(vector.dx) > abs(vector.dy) {
            self = vector.dx > 0 ? .Right : .Left
        }
        else {
            self = vector.dy > 0 ? .Up : .Down
        }
    }
}

protocol ControlInputSourceGameStateDelegate: class {
    func controlInputSourceDidSelect(controlInputSource: ControlInputSourceType)
    func controlInputSource(controlInputSource: ControlInputSourceType, didSpecifyDirection: ControlInputDirection)
    func controlInputSourceDidTogglePauseState(controlInputSource: ControlInputSourceType)
}

protocol ControlInputSourceDelegate: class {
    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateWithMovement movementVelocity: CGVector)

    func controlInputSourceDidSelect(controlInputSource: ControlInputSourceType)
}

protocol ControlInputSourceType: class {
    weak var delegate: ControlInputSourceDelegate? { get set }

    weak var gameStateDelegate: ControlInputSourceGameStateDelegate? { get set }

    func resetControlState()
}