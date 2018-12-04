//
//  MenuScene.swift
//  Feed Me
//
//  Created by Sean Kearney on 04/12/2018.
//  Copyright © 2018 Sean Kearney. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class MenuScene: SKScene{
    
    override func didMove(to view: SKView) {
        setUpScreen()
    }
    
    fileprivate func setUpScreen() {
        var background: SKSpriteNode!
        background = SKSpriteNode(imageNamed: ImageName.Background)
        background.anchorPoint = CGPoint(x: 0, y:0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = Layer.Background
        addChild(background)
        
        var water: SKSpriteNode!
        water = SKSpriteNode(imageNamed: ImageName.Water)
        water.anchorPoint = CGPoint(x: 0, y:0)
        water.position = CGPoint(x: 0, y: 0)
        water.size = CGSize(width: self.size.width, height: self.size.height*0.2139)
        water.zPosition = Layer.Water
        addChild(water)
        
        var startBtn: SKSpriteNode!
        startBtn = SKSpriteNode(imageNamed: ImageName.startBtn)
        startBtn.anchorPoint = CGPoint(x: 0, y: 0)
        startBtn.position = CGPoint(x: self.size.width * 0.7, y: self.size.height * 0.5)
        startBtn.zPosition = Layer.HUD
        startBtn.name = "startBtn"
        addChild(startBtn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches) {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name {
                if name == "startBtn" {
                    let reveal = SKTransition.reveal(with: .down,
                                                     duration: 1)
                    let newScene = GameScene(size: CGSize(width: 750, height: 1334))
                    
                    scene?.view?.presentScene(newScene,
                                            transition: reveal)
                }
            }
        }
    }
}
