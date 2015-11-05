import GameplayKit

class PositionComponent: GKComponent {
    var position = CGPoint.zero
    var rotation = CGFloat(0)

    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)

        if let node = self.entity?.componentForClass(RenderComponent.self)?.node {
            node.position = position
            node.zRotation = rotation
        }
    }
}