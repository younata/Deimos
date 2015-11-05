import Cocoa
import GameplayKit

class KeyboardControlInputSource: ControlInputSourceType {
    weak var delegate: ControlInputSourceDelegate? {
        didSet {
            resetControlState()
        }
    }

    weak var gameStateDelegate: ControlInputSourceGameStateDelegate? {
        didSet {
            resetControlState()
        }
    }

    var selectedCharacters = Set<Character>()

    var movement = CGVector.zero {
        didSet {
            delegate?.controlInputSource(self, didUpdateWithMovement: movement)
        }
    }

    func keyDown(character: Character) {
        if selectedCharacters.contains(character) { return }
        selectedCharacters.insert(character)

        if let velocity = velocityForCharacter(character) {
            movement += velocity
        }
    }

    func keyUp(character: Character) {
        guard selectedCharacters.remove(character) != nil else { return }

        if let velocity = velocityForCharacter(character) {
            movement -= velocity
        } else {
            switch character {
            case "p":
                gameStateDelegate?.controlInputSourceDidTogglePauseState(self)
            default: break
            }
        }
    }

    func resetControlState() {
        selectedCharacters.removeAll()
        movement = CGVector.zero
    }

    private static let forwardVector = CGVector(dx: 0, dy: 1)
    private static let backwardVector = CGVector(dx: 0, dy: -1)
    private static let leftVector = CGVector(dx: -1, dy: 0)
    private static let rightVector = CGVector(dx: 1, dy: 0)

    private func velocityForCharacter(character: Character) -> CGVector? {
        let mapping: [Character: CGVector] = [
            Character(UnicodeScalar(0xF700)):   KeyboardControlInputSource.forwardVector,
            "w":                                KeyboardControlInputSource.forwardVector,
            Character(UnicodeScalar(0xF701)):   KeyboardControlInputSource.backwardVector,
            "s":                                KeyboardControlInputSource.backwardVector,
            Character(UnicodeScalar(0xF702)):   KeyboardControlInputSource.leftVector,
            "a":                                KeyboardControlInputSource.leftVector,
            Character(UnicodeScalar(0xF703)):   KeyboardControlInputSource.rightVector,
            "d":                                KeyboardControlInputSource.rightVector
        ]

        return mapping[character]
    }
}