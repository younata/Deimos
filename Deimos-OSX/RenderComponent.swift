import SpriteKit
import GameplayKit

class RenderComponent: GKComponent {
    let node: SKNode

    init(node: SKNode) {
        self.node = node

        super.init()
    }
}
