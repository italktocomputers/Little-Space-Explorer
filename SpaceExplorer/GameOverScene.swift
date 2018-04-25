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
import iAd

class GameOverScene: SKScene {
    var finalScore = 0
    var difficulty = ""
    var loadTime = NSDate()
    var playedWav = false
    var highScore = 0
    var controller: GameViewController
    var helpers = Helpers()
    
    init(size: CGSize, controller: GameViewController, score: Int, level: String) {
        self.controller = controller
        self.finalScore = score
        self.difficulty = level
        
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to: SKView) {
        if self.controller.iAdError == true {
            if self.controller.isLoadingiAd == false {
                // There was an error loading iAd so let's try again
                self.controller.loadAds()
            }
        }
        else {
            // We already have loaded iAd so let's just show it
            self.controller.adBannerView?.isHidden = false
        }
        
        let lastScore = self.helpers.getLastScore(difficulty: self.difficulty)
        let highScore = self.helpers.getHighScore(difficulty: self.difficulty)
        
        self.highScore = highScore
        
        // Save last score
        self.helpers.saveLastScore(score: self.finalScore, difficulty: self.difficulty)
        
        if self.finalScore > highScore {
            // Save a new high score
            self.helpers.saveHighScore(score: self.finalScore, difficulty: self.difficulty)
            self.showTopScoreBadge()
        }
        
        self.loadBackground()
        self.showStats(lastScore: lastScore, highScore: highScore)
        self.showPointsBadge()
        self.addPlayButton()
    }
    
    func showTopScoreBadge() {
        // top score badge
        let topnode = SKSpriteNode(imageNamed:"badge-11-blank-200x200")
        topnode.position = CGPoint(x:125, y:self.frame.midY+180)
        
        topnode.zPosition = 99
        
        self.addChild(topnode)
        
        self.addChild(
            self.helpers.createLabel(
                text:"Top Score",
                fontSize: 30,
                position: CGPoint(x: topnode.frame.midX, y: topnode.frame.midY-12)
            )
        )
    }
    
    func addPlayButton() {
        let button = SKSpriteNode(imageNamed:"button")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.height-500)
        button.zPosition = 99
        button.name = "play"
        
        self.addChild(button)
        
        self.addChild(
            self.helpers.createLabel(
                text: "Play Again!",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y-12),
                name: "play"
            )
        )
    }
    
    func loadBackground() {
        let background = SKSpriteNode(imageNamed:"bg_single_1536x3840")
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
    }
    
    func showStats(lastScore: Int, highScore: Int) {
        self.addChild(
            self.helpers.createLabel(
                text: "Game Over!",
                fontSize: 50,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY)
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Last score: %i | Highest score: %i", lastScore, highScore),
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+50)
            )
        )
    }
    
    func showPointsBadge() {
        let node = SKSpriteNode(imageNamed:"badge-11-blank-200x200")
        node.position = CGPoint(x: self.frame.midX, y: self.frame.midY+180)
        node.zPosition = 99
        
        self.addChild(node)
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "%i", self.finalScore),
                fontSize: 40,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+165)
            )
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var proceed = false
        
        for touch: AnyObject in touches {
            let location = touch.location(in:self)
            let node = self.atPoint(location)
            
            if node.name == "play" {
                proceed = true
            }
        }
        
        // If proceed is false, they clicked an ad
        if proceed == true {
            let startScene = StartScene(size: self.size, controller: self.controller)
            // Set the scale mode to scale to fit the window
            startScene.scaleMode = .aspectFill
            self.view?.presentScene(startScene)
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        let now = Date()
        let secsSinceLoad = Double(now.timeIntervalSince(self.loadTime as Date))
        
        if round(secsSinceLoad) == 2.0 {
            if self.finalScore > self.highScore && self.playedWav == false {
                let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
                self.run(wav)
                self.playedWav = true
            }
        }

    }

}
