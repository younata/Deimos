import GameplayKit
import SpriteKit

struct EntityDistance {
    let source: GKEntity
    let target: GKEntity
    let distance: CGFloat
}

class MapSnapshot {
    var entitySnapshots: [GKEntity: EntitySnapshot] = [:]

    init(scene: MapScene) {
        func agentForEntity(entity: GKEntity) -> GKAgent2D {
            if let agent = entity.componentForClass(GKAgent2D.self) {
                return agent
            } else if let person = entity as? Person {
                return person.agent
            }
            fatalError("YOU EJIT")
        }

        let entities = scene.entities

        var entityDistances: [GKEntity: [EntityDistance]] = [:]

        for entity in entities {
            entityDistances[entity] = []
        }

        for sourceIndex in entities.startIndex ..< entities.endIndex {
            let sourceEntity = entities[sourceIndex]
            let sourceAgent = agentForEntity(sourceEntity)

            for targetIndex in sourceIndex.successor() ..< entities.endIndex {
                let targetEntity = entities[targetIndex]

                let targetAgent = agentForEntity(targetEntity)

                let dx = targetAgent.position.x - sourceAgent.position.y
                let dy = targetAgent.position.y - sourceAgent.position.y
                let distance = CGFloat(hypotf(dx, dy))

                entityDistances[sourceEntity]?.append(EntityDistance(source: sourceEntity, target: targetEntity, distance: distance))
                entityDistances[targetEntity]?.append(EntityDistance(source: targetEntity, target: sourceEntity, distance: distance))
            }
        }

        for entity in entities {
            entitySnapshots[entity] = EntitySnapshot(entityDistances: entityDistances[entity] ?? [])
        }
    }
}

class EntitySnapshot {
    let entityDistances: [EntityDistance]

    let playerTarget: (target: Person, distance: CGFloat)?

    init(entityDistances: [EntityDistance]) {
        self.entityDistances = entityDistances.sort { $0.distance < $1.distance }

        var playerTarget: (target: Person, distance: CGFloat)? = nil

        for entityDistance in entityDistances {
            if let target = entityDistance.target as? Person where playerTarget == nil {
                playerTarget = (target: target, distance: entityDistance.distance)
                break
            }
        }

        self.playerTarget = playerTarget
    }
}