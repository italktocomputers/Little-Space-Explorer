/*
Copyright (c) 2014, Andrew Schools <andrewschools@me.com>
Permission is hereby granted, free of charge, to any
person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the
Software without restriction, including without
limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the
following conditions:
The above copyright notice and this permission notice
shall be included in all copies or substantial portions
of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import SpriteKit
import AVFoundation
import AudioToolbox
import iAd

let edgeCategory: UInt32 = 0x1 << 0         // 1
let groundCategory: UInt32 = 0x1 << 1       // 2
let spaceshipCategory: UInt32 = 0x1 << 2    // 4
let asteroidCategory: UInt32 = 0x1 << 3     // 8
let pointCategory: UInt32 = 0x1 << 4        // 16

extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if index != nil {
            self.removeAtIndex(index!)
            return true
        }
        
        return false
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var spaceship = SKSpriteNode()
    var nodeQueue: [SKSpriteNode] = []
    var shield = 10
    var audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music", ofType: "wav")!), error: nil)
    var score = 0
    
    var coin1Worth: Int = 2
    var coin2Worth: Int = 3
    var coin3Worth: Int = 4
    var coin4Worth: Int = 5
    
    var minIntervalToAddAsteroid1: Double = 10.0
    var minIntervalToAddAsteroid2: Double = 20.0
    var minIntervalToAddAsteroid4: Double = 20.0
    var minIntervalToAddCoin1: Double = 2.0
    var minIntervalToAddCoin2: Double = 3.0
    var minIntervalToAddCoin3: Double = 10.0
    var minIntervalToAddCoin4: Double = 15.0
    
    var maxIntervalToAddAsteroid1: Double = 10.0
    var maxIntervalToAddAsteroid2: Double = 20.0
    var maxIntervalToAddAsteroid4: Double = 20.0
    var maxIntervalToAddCoin1: Double = 3.0
    var maxIntervalToAddCoin2: Double = 4.0
    var maxIntervalToAddCoin3: Double = 15.0
    var maxIntervalToAddCoin4: Double = 20.0
    
    var randIntervalToAddAsteroid1: Double = 10.0
    var randIntervalToAddAsteroid2: Double = 20.0
    var randIntervalToAddAsteroid4: Double = 20.0
    var randIntervalToAddCoin1: Double = 1.0
    var randIntervalToAddCoin2: Double = 3.0
    var randIntervalToAddCoin3: Double = 10.0
    var randIntervalToAddCoin4: Double = 15.0
    
    var lastTimeAsteroid1Added = NSDate()
    var lastTimeAsteroid2Added = NSDate()
    var lastTimeAsteroid4Added = NSDate()
    var lastTimeCoin1Added = NSDate()
    var lastTimeCoin2Added = NSDate()
    var lastTimeCoin3Added = NSDate()
    var lastTimeCoin4Added = NSDate()
    
    var durationOfAsteroid1 = 10
    var durationOfAsteroid2 = 10
    var durationOfAsteroid4 = 10
    
    var spaceship_shield_indicators: [SKSpriteNode] = []
    
    var direction = ""
    
    var difficulty = ""
    var isGamePaused = false
    var isMusicEnabled = false
    var isGameOver = false
    var controller: GameViewController
    var pauseStartTime: NSDate?
    var helpers = Helpers()
    
    var hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    var gameOverWav = SKAction.playSoundFileNamed("game-over.wav", waitForCompletion: false)
    var collectWav = SKAction.playSoundFileNamed("collect.wav", waitForCompletion: false)
    
    init(size: CGSize, controller: GameViewController, difficulty: String) {
        self.controller = controller
        self.difficulty = difficulty
        
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func yOfGround() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 0
        } else if self.view?.bounds.width == 480 {
            return 50
        } else {
            return 100
        }
    }
    
    func yOfTop() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 768
        } else if self.view?.bounds.width == 480 {
            return 720
        }
        
        return 675
    }
    
    func yMaxPlacementOfItem() -> CGFloat {
        // we want to make sure the koala can
        // reach each item
        return self.yOfTop()-200
    }
    
    func xOfRight() -> CGFloat {
        return 1024
    }
    
    func yPosOfMenuBar() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 728
        } else if self.view?.bounds.width == 480 {
            return 690
        } else {
            return 625
        }
    }
    
    func fromApplicationDidBecomeActive() {
        // not sure why, but if someone hits pause, leaves the game and comes
        // back later, these sound files are no longer in memory so we will
        // reload them here
        self.hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
        self.gameOverWav = SKAction.playSoundFileNamed("game-over.wav", waitForCompletion: false)
        self.collectWav = SKAction.playSoundFileNamed("collect.wav", waitForCompletion: false)
        
        // if the user is returning to this scene we need
        // to call the pause method again since iOS
        // will unpause the game when returning even if
        // the game was paused to begin with
        
        // note: using the self.pause var seems to be unreliable
        // so a new var was created to keep track of game state
        if (self.isGamePaused == true) {
            self.paused = true
        }
    }
    
    func fromApplicationWillResignActive() {
        if self.isGamePaused == false {
            // if they are the leaving game because of a text message,
            // phone call or they just decided to hit the home button
            // mid-game, pause game if not already paused
            self.pause()
        }
    }
    
    func pause(keepTime:Bool=false) {
        self.paused = true
        self.isGamePaused = true
        
        if keepTime == false {
            self.pauseStartTime = NSDate()
        }
        
        if self.isMusicEnabled == true {
            self.audioPlayer.pause()
        }
        
        let accept = SKSpriteNode(imageNamed:"Reloadbtn")
        accept.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame))
        accept.zPosition = 102
        accept.name = "ReloadBtnFromDialog"
        self.addChild(accept)
        
        let warning = SKSpriteNode(imageNamed:"Playbtn")
        warning.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMidY(self.frame))
        warning.zPosition = 102
        warning.name = "PlayBtnFromDialog"
        warning.xScale = 0.7
        warning.yScale = 0.7
        self.addChild(warning)
        
        // show ad
        self.controller.adBannerView!.hidden = false
    }
    
    func cancelPause() {
        self.paused = false
        self.isGamePaused = false
        
        let now = NSDate()
        
        if self.isMusicEnabled == true {
            self.audioPlayer.play()
        }
        
        // since there was a pause we need to make sure that the time elapsed
        // doesn't count towards the add item intervals because if so, items will
        // be immediately added to the scene which would be a cool hack but
        // we cannot allow that...
        
        if self.pauseStartTime != nil {
            let timeElaspedSincePause = Double(now.timeIntervalSinceDate(self.pauseStartTime!))
            
            let pauseIntervalForCoin1 = Double(self.lastTimeCoin1Added.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForCoin2 = Double(self.lastTimeCoin2Added.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForCoin3 = Double(self.lastTimeCoin3Added.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForAsteroid1 = Double(self.lastTimeAsteroid1Added.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForAsteroid2 = Double(self.lastTimeAsteroid2Added.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForAsteroid4 = Double(self.lastTimeAsteroid4Added.timeIntervalSinceDate(pauseStartTime!))
            
            self.lastTimeCoin1Added = NSDate(timeInterval: NSTimeInterval(pauseIntervalForCoin1), sinceDate: now)
            self.lastTimeCoin2Added = NSDate(timeInterval: NSTimeInterval(pauseIntervalForCoin2), sinceDate: now)
            self.lastTimeCoin3Added = NSDate(timeInterval: NSTimeInterval(pauseIntervalForCoin3), sinceDate: now)
            self.lastTimeAsteroid1Added = NSDate(timeInterval: NSTimeInterval(pauseIntervalForAsteroid1), sinceDate: now)
            self.lastTimeAsteroid2Added = NSDate(timeInterval: NSTimeInterval(pauseIntervalForAsteroid2), sinceDate: now)
            self.lastTimeAsteroid4Added = NSDate(timeInterval: NSTimeInterval(pauseIntervalForAsteroid4), sinceDate: now)
        }
        
        self.pauseStartTime = nil
        
        // remove dialog items
        self.enumerateChildNodesWithName("pauseDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("PlayBtnFromDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("ReloadBtnFromDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        // hide ad
        self.controller.adBannerView!.hidden = true
    }
    
    override func didMoveToView(view: SKView) {
        // we need this so the iAd delegates know when to show
        // iAd and when to not
        self.controller.currentSceneName = "GameScene"
        
        // if no error, we will try to display an ad, however, ...
        if self.controller.iAdError == false {
            // no iAd during game play
            self.controller.adBannerView!.hidden = true
        }
        
        // game music
        self.audioPlayer.play()
        self.audioPlayer.numberOfLoops = -1
        
        // add gravity to our game
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        // notify this class when a contact occurs
        self.physicsWorld.contactDelegate = self
        
        if self.difficulty == "medium" {
            self.shield = 3
            
            self.minIntervalToAddAsteroid1 = 2.0
            self.maxIntervalToAddAsteroid1 = 3.0
            self.randIntervalToAddAsteroid1 = 2.0
            
            self.minIntervalToAddAsteroid2 = 3.0
            self.maxIntervalToAddAsteroid2 = 4.0
            self.randIntervalToAddAsteroid2 = 3.0
            
            self.minIntervalToAddAsteroid4 = 4.0
            self.maxIntervalToAddAsteroid4 = 5.0
            self.randIntervalToAddAsteroid4 = 4.0
            
            self.durationOfAsteroid1 = 3
            self.durationOfAsteroid2 = 4
            self.durationOfAsteroid4 = 2
        } else if self.difficulty == "hard" {
            self.shield = 3
            
            self.minIntervalToAddAsteroid1 = 1.0
            self.maxIntervalToAddAsteroid1 = 2.0
            self.randIntervalToAddAsteroid1 = 1.0
            
            self.minIntervalToAddAsteroid2 = 2.0
            self.maxIntervalToAddAsteroid2 = 3.0
            self.randIntervalToAddAsteroid2 = 2.0
            
            self.minIntervalToAddAsteroid4 = 3.0
            self.maxIntervalToAddAsteroid4 = 4.0
            self.randIntervalToAddAsteroid4 = 3.0
            
            self.durationOfAsteroid1 = 2
            self.durationOfAsteroid2 = 3
            self.durationOfAsteroid4 = 1
        } else {
            self.shield = 5
            
            self.minIntervalToAddAsteroid1 = 4.0
            self.maxIntervalToAddAsteroid1 = 6.0
            self.randIntervalToAddAsteroid1 = 4.0
            
            self.minIntervalToAddAsteroid2 = 5.0
            self.maxIntervalToAddAsteroid2 = 8.0
            self.randIntervalToAddAsteroid2 = 5.0
            
            self.minIntervalToAddAsteroid4 = 10.0
            self.maxIntervalToAddAsteroid4 = 20.0
            self.randIntervalToAddAsteroid4 = 10.0
            
            self.durationOfAsteroid1 = 5
            self.durationOfAsteroid2 = 6
            self.durationOfAsteroid4 = 4
        }
        
        self.loadBackground()
        self.addSpaceShip()
        self.addDifficultyLabel()
        self.updateScoreBoard(0)
        self.addShieldIndicator()
        self.addKeyboard()
        self.addPauseButton()
    }
    
    func addPauseButton() {
        let btn = SKSpriteNode(imageNamed:"Pausebtn")
        btn.position = CGPointMake(40, self.yPosOfMenuBar())
        btn.zPosition = 4
        btn.name = name
        btn.xScale = 1
        btn.yScale = 1
        btn.name = "Pause"
        
        self.addChild(btn)
    }
    
    func addKeyboard() {
        var button = SKSpriteNode(imageNamed:"button")
        button.position = CGPointMake(100, self.yOfGround()+50)
        button.zPosition = 99
        button.name = "up"
        button.xScale = 0.5
        button.yScale = 1
        button.alpha = 0.2
        
        self.addChild(button)
        
        self.addChild(self.helpers.createLabel("+", fontSize: 24, position: CGPointMake(CGRectGetMidX(button.frame), CGRectGetMidY(button.frame)-10), name: "up"))
        
        var button2 = SKSpriteNode(imageNamed:"button")
        button2.position = CGPointMake(self.frame.width-100, self.yOfGround()+50)
        button2.zPosition = 99
        button2.name = "down"
        button2.xScale = 0.5
        button2.yScale = 1
        button2.alpha = 0.2
        
        self.addChild(button2)
        
        self.addChild(self.helpers.createLabel("-", fontSize: 24, position: CGPointMake(CGRectGetMidX(button2.frame), CGRectGetMidY(button2.frame)-10), name: "down"))
    }
    
    func updateScoreBoard(score: Int) {
        self.enumerateChildNodesWithName("scoreBoardLabel", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent() // remove current score label
        })
        
        self.addChild(self.helpers.createLabel(String(format: "Points: %i", score), fontSize: 20, position: CGPointMake(self.xOfRight()-100, self.yPosOfMenuBar()+12), name: "scoreBoardLabel"))
    }
    
    func addDifficultyLabel() {
        var diffText = "Easy"
        
        if self.difficulty == "medium" {
            diffText = "Medium"
        } else if self.difficulty == "hard" {
            diffText = "Hard"
        }
        
        self.addChild(self.helpers.createLabel("Difficulty: " + diffText, fontSize: 20, position: CGPointMake(self.xOfRight()-250, self.yPosOfMenuBar()+12), name: "difficultyLabel"))
    }
    
    func addShieldIndicator() {
        self.addChild(self.helpers.createLabel("Shield: ", fontSize: 20, position: CGPoint(x: 115, y: self.yPosOfMenuBar()+12), name: "shield_label"))
        
        for i in 0...self.shield-1 {
            let node = SKSpriteNode(imageNamed:"attack_laser_red")
            let inc = i*Int(node.size.width-15)+175
            node.position = CGPoint(x: CGFloat(inc), y: self.yPosOfMenuBar()+20)
            node.zPosition = 1
            node.name = String(format: "lazer%i", i)
            self.spaceship_shield_indicators.append(node)
            self.addChild(node)
        }
    }
    
    func takeHit() {
        // good guy and bad guy collide so play sound
        self.runAction(self.hitWav)
        
        // blink spaceship red to indicate hit
        let colorRed = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 0.5, duration: 0.2)
        let colorOkay = SKAction.colorizeWithColor(SKColor.clearColor(), colorBlendFactor: 0.0, duration: 0)
        self.spaceship.runAction(SKAction.sequence([colorRed, colorOkay, colorRed, colorOkay]))
        
        self.shield-- // take away from shield
        self.spaceship_shield_indicators.last!.removeFromParent()
        self.spaceship_shield_indicators.removeLast()
        
        if self.shield == 0 {
            // game over!
            self.gameOver()
        }
    }
    
    func gameOver() {
        self.isGameOver = true
        
        self.audioPlayer.stop() // stop game music
        
        // play game over sound
        self.runAction(self.gameOverWav, completion: {()
            // show game over scene
            let gameOverScene = GameOverScene(size: self.size, controller: self.controller, score: self.score, level: self.difficulty)
            gameOverScene.scaleMode = .AspectFill
            self.view?.presentScene(gameOverScene, transition: SKTransition.doorwayWithDuration(2))
        })
    }
    
    // collision between nodes detected
    func didBeginContact(contact: SKPhysicsContact) {
        if self.isGameOver == false {
            let cat1 = contact.bodyA.categoryBitMask
            let cat2 = contact.bodyB.categoryBitMask
            let collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
            
            // spaceship has made contact with a coin
            if collision == pointCategory | spaceshipCategory {
                // play item pickup sound
                self.runAction(self.collectWav)
                
                var coin: SKSpriteNode?
                if contact.bodyA.categoryBitMask == spaceshipCategory {
                    coin = contact.bodyB.node as? SKSpriteNode
                } else {
                    coin = contact.bodyA.node as? SKSpriteNode
                }
                
                if coin!.name == "coin1" {
                    self.score = self.score + self.coin1Worth
                    self.showPointText(String(format: "%i", self.coin1Worth), position: coin!.position)
                } else if coin!.name == "coin2" {
                    self.score = self.score + self.coin2Worth
                    self.showPointText(String(format: "%i", self.coin2Worth), position: coin!.position)
                } else if coin!.name == "coin3" {
                    self.score = self.score + self.coin3Worth
                    self.showPointText(String(format: "%i", self.coin3Worth), position: coin!.position)
                } else if coin!.name == "coin4" {
                    self.score = self.score + self.coin4Worth
                    self.showPointText(String(format: "%i", self.coin4Worth), position: coin!.position)
                }
                
                coin!.removeFromParent()
                self.updateScoreBoard(self.score)
            }
            
            // asteroid has left the scene via x coordinates so let's remove it
            if collision == edgeCategory {
                if round(contact.contactPoint.x) == 0 {
                    if contact.bodyA.categoryBitMask == edgeCategory {
                        contact.bodyB.node!.removeFromParent()
                    } else {
                        contact.bodyA.node!.removeFromParent()
                    }
                }
            }
            
            if collision == spaceshipCategory | asteroidCategory {
                self.takeHit() // spaceship has collided with an asteroid
                
                // spaceship cannot be hit by same asteroid which can happen
                // because they are rotating
                if contact.bodyA.categoryBitMask == asteroidCategory {
                    contact.bodyA.node!.physicsBody!.contactTestBitMask = 0
                } else {
                    contact.bodyA.node!.physicsBody!.contactTestBitMask = 0
                }
            }
        }
    }
    
    // user tapped the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
        }
        
        if nodeName == "Pause" || nodeName == "PlayBtnFromDialog" {
            if self.isGameOver == false {
                if self.paused == true {
                    self.cancelPause()
                } else {
                    self.pause()
                }
            }
        } else if nodeName == "ReloadBtnFromDialog" && self.isGameOver == false {
            // go to main menu
            self.audioPlayer.stop()
            let startScene = StartScene(size: self.size, controller: self.controller)
            startScene.scaleMode = .AspectFill
            self.view?.presentScene(startScene)
        } else if nodeName == "up" {
            self.direction = "up"
        } else if nodeName == "down" {
            self.direction = "down"
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
        }
        
        if nodeName == "up" || nodeName == "down" {
            self.direction = ""
        }
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    func addSpaceShip() {
        var spaceship = SKSpriteNode(imageNamed:"spaceflier_01_a")
        spaceship.position = CGPoint(x: 150, y: 400)
        spaceship.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: spaceship.size.width-125, height: spaceship.size.height-35))
        spaceship.anchorPoint = CGPoint(x: 0.6, y: 0.5)
        spaceship.physicsBody?.restitution = 0
        spaceship.physicsBody?.allowsRotation = false // node should always be upright
        spaceship.physicsBody?.categoryBitMask = spaceshipCategory
        spaceship.physicsBody?.contactTestBitMask = asteroidCategory | groundCategory
        spaceship.physicsBody?.collisionBitMask = groundCategory
        spaceship.physicsBody?.dynamic = true
        spaceship.physicsBody?.affectedByGravity = false
        spaceship.zPosition = 2
        spaceship.yScale = 0.7
        spaceship.xScale = 0.7
        
        // flame
        let move1 = SKTexture(imageNamed: "spaceflier_01_a")
        let move2 = SKTexture(imageNamed: "spaceflier_01_b")
        let move3 = SKTexture(imageNamed: "spaceflier_02_a")
        let move4 = SKTexture(imageNamed: "spaceflier_03_a")
        let move5 = SKTexture(imageNamed: "spaceflier_03_b")
        let moves = SKAction.animateWithTextures([move1, move2, move3, move4, move5], timePerFrame: 0.1)
        
        spaceship.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.spaceship = spaceship
        self.addChild(self.spaceship)
    }
    
    func addAsteroid1() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yOfTop()-100))
        var node = SKSpriteNode(imageNamed:"object_asteroid_01")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(circleOfRadius: 35.0)
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = asteroidCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "asteroid1"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: NSTimeInterval(self.durationOfAsteroid1))
        let rotate = SKAction.rotateByAngle(2, duration: 2)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        node.runAction(SKAction.repeatActionForever(rotate))
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        let now = NSDate()
        let newInterval = self.randRange(UInt32(minIntervalToAddAsteroid1), upper: UInt32(maxIntervalToAddAsteroid1))
        self.randIntervalToAddAsteroid1 = Double(newInterval)
        self.lastTimeAsteroid1Added = NSDate()
    }
    
    func addAsteroid2() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yOfTop()-100))
        var node = SKSpriteNode(imageNamed:"object_asteroid_02")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(circleOfRadius: 45.0)
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = asteroidCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = groundCategory
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "asteroid2"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: NSTimeInterval(self.durationOfAsteroid2))
        let rotate = SKAction.rotateByAngle(2, duration: 6)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        node.runAction(SKAction.repeatActionForever(rotate))
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        let now = NSDate()
        let newInterval = self.randRange(UInt32(minIntervalToAddAsteroid2), upper: UInt32(maxIntervalToAddAsteroid2))
        self.randIntervalToAddAsteroid2 = Double(newInterval)
        self.lastTimeAsteroid2Added = NSDate()
    }
    
    func addAsteroid4() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yOfTop()-100))
        var node = SKSpriteNode(imageNamed:"object_asteroid_04")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = asteroidCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = groundCategory
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "asteroid4"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: NSTimeInterval(self.durationOfAsteroid4))
        let rotate = SKAction.rotateByAngle(2, duration: 2)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        node.runAction(SKAction.repeatActionForever(rotate))
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        let now = NSDate()
        let newInterval = self.randRange(UInt32(minIntervalToAddAsteroid4), upper: UInt32(maxIntervalToAddAsteroid4))
        self.randIntervalToAddAsteroid4 = Double(newInterval)
        self.lastTimeAsteroid4Added = NSDate()
    }
    
    func addCoin1() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"powerup04_1")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "coin1"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: 7)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        
        // blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup04_1")
        let move2 = SKTexture(imageNamed: "powerup04_2")
        let move3 = SKTexture(imageNamed: "powerup04_3")
        let move4 = SKTexture(imageNamed: "powerup04_4")
        let move5 = SKTexture(imageNamed: "powerup04_5")
        let move6 = SKTexture(imageNamed: "powerup04_6")
        let moves = SKAction.animateWithTextures([move1, move2, move3, move4, move5, move6], timePerFrame: 0.1)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddCoin1), upper: UInt32(self.maxIntervalToAddCoin1))
        self.randIntervalToAddCoin1 = Double(newInterval)
        self.lastTimeCoin1Added = NSDate()
    }
    
    func addCoin2() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"powerup03_1")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "coin2"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: 7)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        
        // blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup03_1")
        let move2 = SKTexture(imageNamed: "powerup03_2")
        let move3 = SKTexture(imageNamed: "powerup03_3")
        let move4 = SKTexture(imageNamed: "powerup03_4")
        let move5 = SKTexture(imageNamed: "powerup03_5")
        let move6 = SKTexture(imageNamed: "powerup03_6")
        let moves = SKAction.animateWithTextures([move1, move2, move3, move4, move5, move6], timePerFrame: 0.1)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddCoin2), upper: UInt32(self.maxIntervalToAddCoin2))
        self.randIntervalToAddCoin2 = Double(newInterval)
        self.lastTimeCoin2Added = NSDate()
    }
    
    func addCoin3() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"powerup01_1")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "coin3"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: 7)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        
        // blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup01_1")
        let move2 = SKTexture(imageNamed: "powerup01_2")
        let move3 = SKTexture(imageNamed: "powerup01_3")
        let move4 = SKTexture(imageNamed: "powerup01_4")
        let move5 = SKTexture(imageNamed: "powerup01_5")
        let move6 = SKTexture(imageNamed: "powerup01_6")
        let moves = SKAction.animateWithTextures([move1, move2, move3, move4, move5, move6], timePerFrame: 0.1)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddCoin3), upper: UInt32(self.maxIntervalToAddCoin3))
        self.randIntervalToAddCoin3 = Double(newInterval)
        self.lastTimeCoin3Added = NSDate()
    }
    
    func addCoin4() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"powerup02_1")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = spaceshipCategory
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.name = "coin4"
        
        let deQueue = SKAction.runBlock({()
            self.nodeQueue.removeObject(node)
        })
        
        let move = SKAction.moveToX(-200, duration: 7)
        let removeNode = SKAction.removeFromParent()
        
        node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, deQueue, removeNode])))
        
        // blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup02_1")
        let move2 = SKTexture(imageNamed: "powerup02_2")
        let move3 = SKTexture(imageNamed: "powerup02_3")
        let move4 = SKTexture(imageNamed: "powerup02_4")
        let move5 = SKTexture(imageNamed: "powerup02_5")
        let move6 = SKTexture(imageNamed: "powerup02_6")
        let moves = SKAction.animateWithTextures([move1, move2, move3, move4, move5, move6], timePerFrame: 0.1)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddCoin4), upper: UInt32(self.maxIntervalToAddCoin4))
        self.randIntervalToAddCoin4 = Double(newInterval)
        self.lastTimeCoin4Added = NSDate()
    }
    
    func addToScene() {
        let now = NSDate()
        let intervalForAsteroid1 = Double(now.timeIntervalSinceDate(self.lastTimeAsteroid1Added))
        let intervalForAsteroid2 = Double(now.timeIntervalSinceDate(self.lastTimeAsteroid2Added))
        let intervalForAsteroid4 = Double(now.timeIntervalSinceDate(self.lastTimeAsteroid4Added))
        
        let intervalForCoin1 = Double(now.timeIntervalSinceDate(self.lastTimeCoin1Added))
        let intervalForCoin2 = Double(now.timeIntervalSinceDate(self.lastTimeCoin2Added))
        let intervalForCoin3 = Double(now.timeIntervalSinceDate(self.lastTimeCoin3Added))
        let intervalForCoin4 = Double(now.timeIntervalSinceDate(self.lastTimeCoin4Added))
        
        if intervalForAsteroid1 >= self.randIntervalToAddAsteroid1 {
            self.addAsteroid1()
        }
        
        if intervalForAsteroid2 >= self.randIntervalToAddAsteroid2 {
            self.addAsteroid2()
        }
        
        if intervalForAsteroid4 >= self.randIntervalToAddAsteroid4 {
            self.addAsteroid4()
        }
        
        if intervalForCoin1 >= self.randIntervalToAddCoin1 {
            self.addCoin1()
        }
        
        if intervalForCoin2 >= self.randIntervalToAddCoin2 {
            self.addCoin2()
        }
        
        if intervalForCoin3 >= self.randIntervalToAddCoin3 {
            self.addCoin3()
        }
        
        if intervalForCoin4 >= self.randIntervalToAddCoin4 {
            self.addCoin4()
        }
    }
    
    func loadBackground() {
        // to support a moving background we will add 3 background images,
        // one after another and when one reaches the end of the scene, we will
        // move it to the back so to create an endless moving background
        for i in 0...9 {
            var bg = SKSpriteNode(imageNamed:"bg_parallax_stars_1536x3840")
            
            bg.position = CGPointMake(CGFloat(i * Int(bg.size.width)), self.size.height/2)
            bg.name = "background";
            self.addChild(bg)
        }
        
        // add invisible barrier so our nodes don't go too high
        let topBody = SKNode()
        topBody.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: CGFloat(self.yOfTop())-self.spaceship.size.height), toPoint: CGPoint(x: self.xOfRight(), y: CGFloat(self.yOfTop())-self.spaceship.size.height))
        
        topBody.physicsBody?.restitution = 0
        topBody.physicsBody?.categoryBitMask = groundCategory
        topBody.physicsBody?.dynamic = false
        self.addChild(topBody)
        
        // add invisible barrier so our nodes don't go too low
        let groundBody = SKNode()
        groundBody.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: self.yOfGround()+self.spaceship.size.height), toPoint: CGPoint(x: self.xOfRight(), y: self.yOfGround()+self.spaceship.size.height))
        
        groundBody.physicsBody?.restitution = 0
        groundBody.physicsBody?.categoryBitMask = groundCategory
        groundBody.physicsBody?.dynamic = false
        self.addChild(groundBody)
    }
    
    func showTextBurst(text: String, size: CGFloat) {
        let label = SKLabelNode(fontNamed: "KohinoorDevanagari-Medium")
        label.text = text
        label.fontColor = SKColor.whiteColor()
        label.fontSize = size
        label.zPosition = 10
        label.position = CGPointMake(self.xOfRight()/2, self.yOfTop()/2)
        label.alpha = CGFloat(0.1)
        
        let scale = SKAction.scaleTo(CGFloat(30), duration: 1)
        let remove = SKAction.removeFromParent()
        
        label.runAction(SKAction.sequence([scale, remove]))
        
        self.addChild(label)
    }
    
    func showPointText(text: String, position: CGPoint) {
        let label = SKLabelNode(fontNamed: "KohinoorDevanagari-Medium")
        label.text = text
        label.fontColor = SKColor.whiteColor()
        label.fontSize = 24
        label.zPosition = 99
        label.position = position
        
        let move = SKAction.moveToY(position.y+50, duration: 1)
        let remove = SKAction.removeFromParent()
        
        label.runAction(SKAction.sequence([move, remove]))
        
        self.addChild(label)
    }
    
    override func update(currentTime: CFTimeInterval) {
        if self.isGamePaused == true {
            // not sure why I need to do this but if the user hits the home
            // button and it's longer than a couple of minutes before they
            // return, iOS will play the game even though it should be paused
            self.paused = true
        }
        
        if self.isGamePaused == false && self.isGameOver == false {
            // loop through our background images, moving each one 5 points to the left
            // if one image reaches the end of the scene, we will place it in the back
            self.enumerateChildNodesWithName("background", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let bg = node as! SKSpriteNode
                // move background to the left 5 points
                bg.position = CGPointMake(bg.position.x - 2, bg.position.y)
                
                // if background has moved out of scene, move it to the end
                if (bg.position.x <= -bg.size.width) {
                    bg.position = CGPointMake(bg.position.x + bg.size.width * 3, bg.position.y)
                }
            })
            
            if self.direction == "up" {
                self.spaceship.position.y += 10
            } else if self.direction == "down" {
                self.spaceship.position.y -= 10
            }
            
            self.addToScene()
        }
    }
}
