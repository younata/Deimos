import GameplayKit
import SpriteKit

class AIBehavior: GKBehavior {
    static func behaviorForAgent(agent: GKAgent2D, returnToPoint point: CGPoint, radius: CGFloat, inScene scene: MapScene) -> GKBehavior {
        let behavior = AIBehavior()

        behavior.addAvoidObstaclesGoalForScene(scene)
        behavior.addTargetSpeedGoal(agent.maxSpeed)

        let pathVectorPoints = [point].map(float2.init)
        let path = GKPath(points: UnsafeMutablePointer<float2>(pathVectorPoints), count: 1, radius: Float(radius), cyclical: false)
        behavior.setWeight(1.0, forGoal: GKGoal(toStayOnPath: path, maxPredictionTime: 1))

        return behavior
    }

    static func behaviorForAgent(agent: GKAgent2D, patrollingPathWithPoints patrolPathPoints: [CGPoint], pathRadius: CGFloat, inScene scene: MapScene) -> GKBehavior {
        let behavior = AIBehavior()

        behavior.addAvoidObstaclesGoalForScene(scene)
        behavior.addTargetSpeedGoal(agent.maxSpeed)

        let pathVectorPoints = patrolPathPoints.map(float2.init)
        let path = GKPath(points: UnsafeMutablePointer<float2>(pathVectorPoints), count: pathVectorPoints.count, radius: Float(pathRadius), cyclical: true)
        behavior.addFollowAndStayOnPathGoalsForPath(path)

        return behavior
    }

    private func addAvoidObstaclesGoalForScene(scene: MapScene) {
        setWeight(1.0, forGoal: GKGoal(toAvoidObstacles: scene.polygonObstacles, maxPredictionTime: 1))
    }

    /// Adds a goal to attain a target speed.
    private func addTargetSpeedGoal(speed: Float) {
        setWeight(0.5, forGoal: GKGoal(toReachTargetSpeed: speed))
    }

    /// Adds goals to follow and stay on a path.
    private func addFollowAndStayOnPathGoalsForPath(path: GKPath) {
        setWeight(1.0, forGoal: GKGoal(toFollowPath: path, maxPredictionTime: 1, forward: true))
        setWeight(1.0, forGoal: GKGoal(toStayOnPath: path, maxPredictionTime: 1))
    }
}