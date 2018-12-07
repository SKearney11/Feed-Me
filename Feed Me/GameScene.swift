import SpriteKit
import AVFoundation

private var crocodile: SKSpriteNode!
private var prize: SKSpriteNode!
private var sliceSoundAction: SKAction!
private var splashSoundAction: SKAction!
private var nomNomSoundAction: SKAction!
private var levelOver = false
private var vineCut = false
var numberOfLives = 3
var crocsFed = 0
var crocsFedLabel: SKLabelNode!

class GameScene: SKScene, SKPhysicsContactDelegate {

    override func didMove(to view: SKView) {
        setUpHud()
        levelOver = false
        setUpPhysics()
        setUpScenery()
        setUpPrize()
        setUpVines()
        setUpCrocodile()
        setUpAudio()
    }
    
    //MARK: - Level setup
    
    fileprivate func setUpHud(){
        for i in 1...numberOfLives {
            var heart: SKSpriteNode!
            heart = SKSpriteNode(imageNamed: ImageName.lives)
            heart.anchorPoint = CGPoint(x: 0, y: 0)
            heart.position = CGPoint(x: CGFloat(i * 60) , y: self.size.height * 0.92)
            heart.zPosition = Layer.HUD
            heart.name = ("heart" + String(i))
            addChild(heart)
        }
        
        var optionsBtn: SKSpriteNode!
        optionsBtn = SKSpriteNode(imageNamed: ImageName.menuBtn)
        optionsBtn.anchorPoint = CGPoint(x: 0, y: 0)
        optionsBtn.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.92)
        optionsBtn.zPosition = Layer.HUD
        optionsBtn.name = "optionsBtn"
        optionsBtn.size = CGSize(width: 100, height: 90)
        addChild(optionsBtn)
    }
    
    fileprivate func setUpPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
    }
    
    fileprivate func setUpScenery() {
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
        
        crocsFedLabel = SKLabelNode(fontNamed: "Chalkduster")
        crocsFedLabel.text = "Crocs Fed: "+String(crocsFed)
        crocsFedLabel.fontSize = 35
        crocsFedLabel.position = CGPoint(x: self.size.width/2, y: 35)
        crocsFedLabel.zPosition = Layer.HUD
        self.addChild(crocsFedLabel)
    }
    fileprivate func setUpPrize() {
        prize = SKSpriteNode(imageNamed: ImageName.Prize)
        prize.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        prize.zPosition = Layer.Prize
        prize.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.Prize), size: prize.size)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.Prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5
        prize.physicsBody?.isDynamic = true
        addChild(prize)
    }
    
    //MARK: - Vine methods
    
    fileprivate func setUpVines() {
        // 2 add vines
        let numOfVines = (Int(arc4random_uniform(4) + 1))
        for i in 0..<numOfVines {
            // 3 create vine
            let length = Int(arc4random_uniform(8) + 10)
            let anchorPoint = CGPoint(x: Int(arc4random_uniform(UInt32(size.width))),
                                      y: Int(arc4random_uniform(UInt32(150)))+Int(size.height*0.8))
            let vine = VineNode(length: length, anchorPoint: anchorPoint, name: "\(i)")
            // 4 add to scene
            vine.addToScene(self)
            // 5 connect the other end of the vine to the prize
            vine.attachToPrize(prize)
        }
    }
    
    //MARK: - Croc methods
    
    fileprivate func setUpCrocodile() {
        crocodile = SKSpriteNode(imageNamed: ImageName.CrocMouthClosed)
        crocodile.position = CGPoint(x: self.size.width*0.75, y: self.size.height*0.312)
        crocodile.zPosition = Layer.Crocodile
        crocodile.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.CrocMask), size: crocodile.size)
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.Crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.Prize
        crocodile.physicsBody?.isDynamic = false
        addChild(crocodile)
        animateCrocodile()
    }
    fileprivate func animateCrocodile() {
        let durationOpen = drand48()+2
        let open = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
        let waitOpen = SKAction.wait(forDuration: durationOpen)
        let durationClosed = drand48()+drand48()+3.0
        let close = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
        let waitClosed = SKAction.wait(forDuration: durationClosed)
        let sequence = SKAction.sequence([waitOpen, open, waitClosed, close])
        let loop = SKAction.repeatForever(sequence)
        crocodile.run(loop)
    }
    
    fileprivate func runNomNomAnimationWithDelay(_ delay: TimeInterval) {
        crocodile.removeAllActions()
        
        let closeMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
        let wait = SKAction.wait(forDuration: delay)
        let openMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
        let sequence = SKAction.sequence([closeMouth, wait, openMouth, wait, closeMouth])
        
        crocodile.run(sequence)
        // transition to next level
        switchToNewGameWithTransition(SKTransition.doorway(withDuration: 1.0))
    }
    
    //MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        vineCut = false
        
        for touch in (touches) {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name {
                if name == "optionsBtn" {
                    let reveal = SKTransition.reveal(with: .down,
                                                     duration: 1)
                    let newScene = MenuScene(size: CGSize(width: 750, height: 1334))
                    crocsFed = 0
                    numberOfLives = 3
                    scene?.view?.presentScene(newScene,
                                              transition: reveal)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)
            
            // check if vine cut
            scene?.physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint,
                                                using: { (body, point, normal, stop) in
                                                    self.checkIfVineCutWithBody(body)
            })
            
            // produce some nice particles
            showMoveParticles(touchPosition: startPoint)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { }
    fileprivate func showMoveParticles(touchPosition: CGPoint) { }
    
    //MARK: - Game logic
    
    override func update(_ currentTime: TimeInterval) {
        if levelOver {
            return
        }
        if prize.position.y <= 0 {
            levelOver = true
            run(splashSoundAction)
            numberOfLives = numberOfLives - 1
            if(numberOfLives < 1){
                crocsFed = 0
                numberOfLives = 3
                let reveal = SKTransition.reveal(with: .down,
                                                 duration: 1)
                let newScene = MenuScene(size: CGSize(width: 750, height: 1334))
                
                scene?.view?.presentScene(newScene,
                                          transition: reveal)
            
            }
            switchToNewGameWithTransition(SKTransition.fade(withDuration: 1.0))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if levelOver {
            return
        }
        if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
            || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
            levelOver = true
            // shrink the pineapple away
            crocsFed = crocsFed+1
            let shrink = SKAction.scale(to: 0, duration: 0.08)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([shrink, removeNode])
            prize.run(sequence)
            runNomNomAnimationWithDelay(0.15)
            run(nomNomSoundAction)
        }
    }
    
    fileprivate func checkIfVineCutWithBody(_ body: SKPhysicsBody) {
        if vineCut && multiSwipeBool == false {
            return
        }
        let node = body.node!
        // if it has a name it must be a vine node
        if let name = node.name {
            // snip the vine
            node.removeFromParent()
            run(sliceSoundAction)
            // fade out all nodes matching name
            enumerateChildNodes(withName: name, using: { (node, stop) in
                let fadeAway = SKAction.fadeOut(withDuration: 0.25)
                let removeNode = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fadeAway, removeNode])
                node.run(sequence)
            })
            crocodile.removeAllActions()
            crocodile.texture = SKTexture(imageNamed: ImageName.CrocMouthOpen)
            animateCrocodile()
        }
        vineCut = true
    }
    fileprivate func switchToNewGameWithTransition(_ transition: SKTransition) {
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run({
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: transition)
        })
        
        run(SKAction.sequence([delay, sceneChange]))
    }
    
    //MARK: - Audio
    private static var backgroundMusicPlayer: AVAudioPlayer!
    
    fileprivate func setUpAudio() {
        
        if GameScene.backgroundMusicPlayer == nil {
            sliceSoundAction = SKAction.playSoundFileNamed(SoundFile.Slice, waitForCompletion: false)
            splashSoundAction = SKAction.playSoundFileNamed(SoundFile.Splash, waitForCompletion: false)
            nomNomSoundAction = SKAction.playSoundFileNamed(SoundFile.NomNom, waitForCompletion: false)
        }
    }
}
