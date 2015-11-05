import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        let scene = MapScene()
        scene.backgroundColor = NSColor.whiteColor()
        scene.scaleMode = .AspectFill

        scene.size = self.skView!.frame.size
        
        self.skView!.presentScene(scene)

        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true

        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
