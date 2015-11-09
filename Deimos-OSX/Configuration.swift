import CoreGraphics
import SpriteKit

struct Configuration {
    static let MazeSideLength: CGFloat = unitRadius * 2
    static let MazeWallColor = SKColor.blackColor()
    static let MazeFloorColor = SKColor.grayColor()
    static let proximityFactor: CGFloat = 800
    static let unitRadius: CGFloat = 20
}