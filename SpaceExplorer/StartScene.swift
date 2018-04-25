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

class StartScene: SKScene {
    var controller: GameViewController
    var helpers = Helpers()
    
    init(size: CGSize, controller: GameViewController) {
        self.controller = controller
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
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
        
        let highScore = self.helpers.getHighScore(difficulty: "easy")
        let highScore2 = self.helpers.getHighScore(difficulty: "medium")
        let highScore3 = self.helpers.getHighScore(difficulty: "hard")
        
        let lastScore = self.helpers.getLastScore(difficulty: "easy")
        let lastScore2 = self.helpers.getLastScore(difficulty: "medium")
        let lastScore3 = self.helpers.getLastScore(difficulty: "hard")
        
        let background = SKSpriteNode(imageNamed:"bg_single_1536x3840")
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
        
        self.addChild(
            self.helpers.createLabel(
                text: "Little Space Explorer",
                fontSize: 42,
                position: CGPoint(x: self.frame.midX, y: self.frame.height-175)
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: "Help/Info",
                fontSize: 24,
                position: CGPoint(x: self.frame.width-100, y: self.frame.height-150),
                name: "help"
            )
        )
        
        self.addEasyButton(highscore: highScore, lastScore: lastScore)
        self.addMediumButton(highscore: highScore2, lastScore: lastScore2)
        self.addHardButton(highscore: highScore3, lastScore: lastScore3)
    }
    
    func addEasyButton(highscore: Int, lastScore: Int) {
        let button = SKSpriteNode(imageNamed:"button")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.height-250)
        button.zPosition = 99
        button.name = "easy"
        
        self.addChild(button)
        
        self.addChild(
            self.helpers.createLabel(
                text: "Easy",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y),
                name: "easy"
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "High score: %i | Last Score: %i", highscore, lastScore),
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y-25),
                name: "easy"
            )
        )
    }
    
    func addMediumButton(highscore: Int, lastScore: Int) {
        let button = SKSpriteNode(imageNamed:"button")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.height-375)
        button.zPosition = 99
        button.name = "medium"
        
        self.addChild(button)
        
        self.addChild(
            self.helpers.createLabel(
                text: "Medium",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y),
                name: "medium"
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "High score: %i | Last Score: %i", highscore, lastScore),
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y-25),
                name: "medium"
            )
        )
    }
    
    func addHardButton(highscore: Int, lastScore: Int) {
        let button = SKSpriteNode(imageNamed:"button")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.height-500)
        button.zPosition = 99
        button.name = "hard"
        
        self.addChild(button)
        
        self.addChild(
            self.helpers.createLabel(
                text: "Hard",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y),
                name: "hard"
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "High score: %i | Last Score: %i", highscore, lastScore),
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: button.position.y-25),
                name: "hard"
            )
        )
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var difficulty = ""
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in:self)
            let node = self.atPoint(location)
            
            // If fire button touched, bring the rain
            if node.name == "medium" {
                difficulty = "medium"
            }
            else if node.name == "hard" {
                difficulty = "hard"
            }
            else if node.name == "easy" {
                difficulty = "easy"
            }
            
            if node.name != nil {
                nodeName = node.name!
            }
        }
        
        // If difficulty is empty, they clicked an ad
        if difficulty != "" {
            let gameScene = GameScene(size: self.size, controller: self.controller, difficulty: difficulty)
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene)
        }
        else {
            if nodeName == "help" {
                let scene = HelpScene(size: self.size, controller: self.controller)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}
