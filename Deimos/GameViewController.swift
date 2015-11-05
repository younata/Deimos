import UIKit
import SpriteKit
import PureLayout

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = SKView(forAutoLayout: ())
            self.view.addSubview(skView)
            skView.autoPinEdgesToSuperviewEdges()
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true

            scene.scaleMode = .AspectFill

            skView.presentScene(scene)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
