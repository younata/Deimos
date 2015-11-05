import SpriteKit

enum ArrowDirection {
    case Up, Down, Left, Right

    init?(keyCode: UInt16) {
        if keyCode == 126 {
            self = .Up
        } else if keyCode == 125 {
            self = .Down
        } else if keyCode == 123 {
            self = .Left
        } else if keyCode == 124 {
            self = .Right
        } else {
            return nil
        }
    }

    var vector: CGVector {
        let x: CGFloat, y: CGFloat
        switch (self) {
        case .Up:
            (x, y) = (0, 1)
        case .Down:
            (x, y) = (0, -1)
        case .Left:
            (x, y) = (-1, 0)
        case .Right:
            (x, y) = (1, 0)
        }
        return CGVector(dx: x, dy: y)
    }
}

class GameScene: SKScene {
    lazy var person: Person = {
        return Person()
    }()

    let inputSource = KeyboardControlInputSource()

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        person.componentForClass(PositionComponent.self)?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        if let node = person.componentForClass(RenderComponent.self)?.node {
            self.addChild(node)
        }
        if let input = person.componentForClass(InputComponent.self) {
            inputSource.delegate = input
        }
    }

    override func keyDown(event: NSEvent) {
        guard let characters = event.characters?.characters else { return }
        for char in characters {
            inputSource.keyDown(char)
        }
    }

    override func keyUp(event: NSEvent) {
        guard let characters = event.characters?.characters else { return }
        for char in characters {
            inputSource.keyUp(char)
        }
    }

    var lastUpdateTimeInterval: CFTimeInterval = 0
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        guard lastUpdateTimeInterval > 0 else {
            lastUpdateTimeInterval = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        person.updateWithDeltaTime(deltaTime)
    }
}
