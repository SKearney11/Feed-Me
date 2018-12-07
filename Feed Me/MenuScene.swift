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

var musicMute = false
var multiSwipeBool = false
var muteBtn: SKSpriteNode!
var multiSwipeBtn:SKSpriteNode!

class MenuScene: SKScene{
    
    override func didMove(to view: SKView) {
        setUpScreen()
        setUpAudio()
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
        startBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startBtn.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        startBtn.zPosition = Layer.HUD
        startBtn.name = "startBtn"
        startBtn.size = CGSize(width: 300, height: 300)
        addChild(startBtn)
        
        muteBtn = SKSpriteNode(imageNamed: ImageName.muteBtn)
        muteBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        muteBtn.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3)
        muteBtn.zPosition = Layer.HUD
        muteBtn.name = "muteBtn"
        muteBtn.size = CGSize(width: 150, height: 150)
        addChild(muteBtn)
        
        multiSwipeBtn = SKSpriteNode(imageNamed: ImageName.multiSwipeOff)
        multiSwipeBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        multiSwipeBtn.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.15)
        multiSwipeBtn.zPosition = Layer.HUD
        multiSwipeBtn.name = "multiSwipeBtn"
        multiSwipeBtn.size = CGSize(width: 330, height: 110)
        addChild(multiSwipeBtn)
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
                if name == "muteBtn" {
                    musicMute = !musicMute
                    
                    if !MenuScene.backgroundMusicPlayer.isPlaying && musicMute == false{
                        MenuScene.backgroundMusicPlayer.play()
                        muteBtn.texture = SKTexture(imageNamed: ImageName.muteBtnOff)
                    } else{
                        MenuScene.backgroundMusicPlayer.stop()
                        muteBtn.texture = SKTexture(imageNamed: ImageName.muteBtn)
                    }
                }
                if name == "multiSwipeBtn" {
                    multiSwipeBool = !multiSwipeBool
                    
                    if multiSwipeBool == true{
                        multiSwipeBtn.texture = SKTexture(imageNamed: ImageName.multiSwipeOn)
                    } else{
                        multiSwipeBtn.texture = SKTexture(imageNamed: ImageName.multiSwipeOff)
                    }
                }
            }
        }
    }
    
    private static var backgroundMusicPlayer: AVAudioPlayer!
    
    fileprivate func setUpAudio() {
        if MenuScene.backgroundMusicPlayer == nil {
            let backgroundMusicURL = Bundle.main.url(forResource: SoundFile.BackgroundMusic, withExtension: nil)
            do {
                let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
                MenuScene.backgroundMusicPlayer = theme
            } catch {
                // couldn't load file :[
            }
            MenuScene.backgroundMusicPlayer.numberOfLoops = -1
            if !MenuScene.backgroundMusicPlayer.isPlaying && musicMute == false{
                MenuScene.backgroundMusicPlayer.play()
            }
        }
    }
}
