//
//  VineNode.swift
//  Feed Me
//
//  Created by Sean Kearney on 19/11/2018.
//  Copyright © 2018 Sean Kearney. All rights reserved.
//

import Foundation
import SpriteKit

class VineNode: SKNode {
    
    private let length: Int
    private let anchorPoint: CGPoint
    private var vineSegments: [SKNode] = []
    
    init(length: Int, anchorPoint: CGPoint, name: String) {
        
        self.length = length
        self.anchorPoint = anchorPoint
        
        super.init()
        
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        length = aDecoder.decodeInteger(forKey: "length")
        anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")
        
        super.init(coder: aDecoder)
    }
    
    func addToScene(_ scene: SKScene) {
        // add vine to scene
        zPosition = Layer.Vine
        scene.addChild(self)
        // create vine root
        let vineRoot = SKSpriteNode(imageNamed: ImageName.VineRoot)
        vineRoot.position = anchorPoint
        vineRoot.zPosition = 1
        
        addChild(vineRoot)
        
        vineRoot.physicsBody = SKPhysicsBody(circleOfRadius: vineRoot.size.width / 2)
        vineRoot.physicsBody?.isDynamic = false
        vineRoot.physicsBody?.categoryBitMask = PhysicsCategory.VineRoot
        vineRoot.physicsBody?.collisionBitMask = 0
        // add each of the vine parts
        for i in 0..<length {
            let vineSegment = SKSpriteNode(imageNamed: ImageName.Vine)
            let offset = vineSegment.size.height * CGFloat(i + 1)
            vineSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
            vineSegment.name = name
            
            vineSegments.append(vineSegment)
            addChild(vineSegment)
            
            vineSegment.physicsBody = SKPhysicsBody(rectangleOf: vineSegment.size)
            vineSegment.physicsBody?.categoryBitMask = PhysicsCategory.Vine
            vineSegment.physicsBody?.collisionBitMask = PhysicsCategory.VineRoot
        }
        // set up joint for vine root
        let joint = SKPhysicsJointPin.joint(withBodyA: vineRoot.physicsBody!,
                                            bodyB: vineSegments[0].physicsBody!,
                                            anchor: CGPoint(x: vineRoot.frame.midX, y: vineRoot.frame.midY))
        scene.physicsWorld.add(joint)
        
        // set up joints between vine parts
        for i in 1..<length {
            let nodeA = vineSegments[i - 1]
            let nodeB = vineSegments[i]
            let joint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY))
            scene.physicsWorld.add(joint)
        }
    }
    
    func attachToPrize(_ prize: SKSpriteNode) {
        // align last segment of vine with prize
        let lastNode = vineSegments.last!
        lastNode.position = CGPoint(x: prize.position.x, y: prize.position.y + prize.size.height * 0.1)
        
        // set up connecting joint
        let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                                            bodyB: prize.physicsBody!, anchor: lastNode.position)
        
        prize.scene?.physicsWorld.add(joint)
    }
}


