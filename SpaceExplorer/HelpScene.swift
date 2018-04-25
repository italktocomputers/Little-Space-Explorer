/*
Copyright (c) 2015, Andrew Schools <andrewschools@me.com>
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

class HelpScene: SKScene {
    var helpFilePos = 0
    var controller: GameViewController
    var currentPage = 1
    var totalPages = 4
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
        
        let background = SKSpriteNode(imageNamed:"bg_single_1536x3840")
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
        
        self.showFirstHelpFile()
        self.addBackButton()
        self.addForwardButton()
    }
    
    func addForwardButton() {
        let node = SKSpriteNode(imageNamed:"Forwardbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPoint(x: self.frame.width-50, y: self.frame.midY)
        node.zPosition = 1
        node.name = "Forward"
        self.addChild(node)
    }
    
    func addBackButton() {
        let node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPoint(x: 50, y: self.frame.midY)
        node.zPosition = 1
        node.name = "Back"
        self.addChild(node)
    }
    
    func showFirstHelpFile() {
        let text: [String] = [
            "Click + to move up, - to move down.",
            "Your goal is to collect as many space coins as possible",
            "without running into any asteroids.  Be carefully though because the asteroids",
            "move at different speeds.  Luckily your little ship has a shield.  Your shield's",
            "power is indicated in the upper left part of the screen.  If you run out of",
            "red bars, game over as your shield has been depleted."
        ]
        
        var i = 0
        for line in text {
            self.addChild(
                self.helpers.createLabel(
                    text: line,
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-150))-(i*30))),
                    name: "help_text"
                )
            )
            
            i+=1
        }
    }
    
    func removeHelpFileNodes() {
        // We need to hide our first set of nodes
        self.enumerateChildNodes(
            withName: "help_text",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        self.enumerateChildNodes(
            withName: "KrazyKoala",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
    }
    
    func showCoin1Info() {
        let text: [String] = [
            "-2-",
            "points"
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(
                self.helpers.createLabel(
                    text: line,
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX-200, y: y),
                    name: "help_text"
                )
            )
            
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"powerup04_1")
        node.position = CGPoint(x: self.frame.midX-200, y: y-35)
        node.name = "help_text"
        
        // Blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup04_1")
        let move2 = SKTexture(imageNamed: "powerup04_2")
        let move3 = SKTexture(imageNamed: "powerup04_3")
        let move4 = SKTexture(imageNamed: "powerup04_4")
        let move5 = SKTexture(imageNamed: "powerup04_5")
        let move6 = SKTexture(imageNamed: "powerup04_6")
        
        let moves = SKAction.animate(
            with: [move1, move2, move3, move4, move5, move6],
            timePerFrame: 0.1
        )
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        self.addChild(node)
    }
    
    func showCoin2Info() {
        let text: [String] = [
            "-3-",
            "points"
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            
            self.addChild(
                self.helpers.createLabel(
                    text: line,
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX-100, y: y),
                    name: "help_text"
                )
            )
            
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"powerup03_1")
        node.position = CGPoint(x: self.frame.midX-100, y: y-35)
        node.name = "help_text"
        
        // blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup03_1")
        let move2 = SKTexture(imageNamed: "powerup03_2")
        let move3 = SKTexture(imageNamed: "powerup03_3")
        let move4 = SKTexture(imageNamed: "powerup03_4")
        let move5 = SKTexture(imageNamed: "powerup03_5")
        let move6 = SKTexture(imageNamed: "powerup03_6")
        
        let moves = SKAction.animate(
            with: [move1, move2, move3, move4, move5, move6],
            timePerFrame: 0.1
        )
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        self.addChild(node)
    }
    
    func showCoin3Info() {
        let text: [String] = [
            "-4-",
            "points"
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            
            self.addChild(
                self.helpers.createLabel(
                    text: line,
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX+100, y: y),
                    name: "help_text"
                )
            )
            
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"powerup01_1")
        node.position = CGPoint(x: self.frame.midX+100, y: y-35)
        node.name = "help_text"
        
        // Blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup01_1")
        let move2 = SKTexture(imageNamed: "powerup01_2")
        let move3 = SKTexture(imageNamed: "powerup01_3")
        let move4 = SKTexture(imageNamed: "powerup01_4")
        let move5 = SKTexture(imageNamed: "powerup01_5")
        let move6 = SKTexture(imageNamed: "powerup01_6")
        
        let moves = SKAction.animate(
            with: [move1, move2, move3, move4, move5, move6],
            timePerFrame: 0.1
        )
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        self.addChild(node)
    }
    
    func showCoin4Info() {
        let text: [String] = [
            "-5-",
            "points",
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            
            self.addChild(
                self.helpers.createLabel(
                    text: line,
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX+200, y: y),
                    name: "help_text"
                )
            )
            
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"powerup02_1")
        node.position = CGPoint(x: self.frame.midX+200, y: y-35)
        node.name = "help_text"
        
        // Blink so user notices it
        let move1 = SKTexture(imageNamed: "powerup02_1")
        let move2 = SKTexture(imageNamed: "powerup02_2")
        let move3 = SKTexture(imageNamed: "powerup02_3")
        let move4 = SKTexture(imageNamed: "powerup02_4")
        let move5 = SKTexture(imageNamed: "powerup02_5")
        let move6 = SKTexture(imageNamed: "powerup02_6")
        
        let moves = SKAction.animate(
            with: [move1, move2, move3, move4, move5, move6],
            timePerFrame: 0.1
        )
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        self.addChild(node)
    }
    
    func showSecondHelpFile() {
        
        self.addChild(
            self.helpers.createLabel(
                text: "Types of coins you can collect:",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: self.size.height - 150),
                name: "help_text"
            )
        )
        
        self.showCoin1Info()
        self.showCoin2Info()
        self.showCoin3Info()
        self.showCoin4Info()
    }
    
    func showThirdHelpFile() {
        let text: [String] = [
            "All audio was provided by http://www.freesound.org/",
            "and is licensed under the Creative Commons 0 License which",
            "can be viewed here: http://creativecommons.org/publicdomain/zero/1.0/.",
            "",
            "Most artwork was provided by Vicki Wenderlich @",
            "http://www.gameartguppy.com/ which is licensed under the Creative",
            "Commons Attribution License which can be viewed here:",
            "http://creativecommons.org/licenses/by/2.0/, and by ",
            "http://graphicburger.com which provides royalty free art.",
            "",
            "All other work was created and is owned by Andrew Schools.",
            "Copyright 2015, Andrew Schools."
        ]
        
        var i = 0
        
        for line in text {
            self.addChild(
                self.helpers.createLabel(
                    text: line,
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-150))-(i*30))),
                    name: "help_text"
                )
            )
            
            i+=1
        }

    }
    
    func showPageNum() {
        self.enumerateChildNodes(
            withName: "pageNums",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format:"Page %i of %i", self.currentPage, self.totalPages),
                fontSize: 10,
                position: CGPoint(x: self.frame.midX+500, y: self.frame.midY-200),
                name: "pageNums"
            )
        )
    }
    
    func showKrazyKoalaAdInfo() {
        self.addChild(
            self.helpers.createLabel(
                text: "Other Games",
                fontSize: 36,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+200),
                name: "help_text"
            )
        )
        
        let text: [String] = [
            "Check out my other game Krazy Koala.",
            "Like Little Space Explorer, it's free and addictive!",
            "Click image below to download from the App Store."
        ]
        
        var i = 0
        for line in text {
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 24,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-250))-(i*30))),
                    name: "help_text",
                    color: SKColor.white
                )
            )
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"KrazyKoala640x640.jpg")
        node.position = CGPoint(x: self.frame.midX, y: self.frame.midY-50)
        node.name = "KrazyKoala"
        node.zPosition = 100
        node.xScale = 0.6
        node.yScale = 0.6
        
        self.addChild(node)
    }
    
    func openAppStore() {
        let iTunesLink = "https://itunes.apple.com/us/app/krazykoala/id957148297?mt=8"
        UIApplication.shared.openURL(NSURL(string: iTunesLink)! as URL)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in:self)
            let node = self.atPoint(location)
            var nodeName = ""
            var moveButtonPressed = false
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Forward" {
                self.helpFilePos+=1
                moveButtonPressed = true
                self.currentPage+=1
                self.showPageNum()
            }
            else if nodeName == "Back" {
                self.helpFilePos-=1
                moveButtonPressed = true
                self.currentPage-=1
                self.showPageNum()
            }
            
            if moveButtonPressed == true {
                if self.helpFilePos == 0 {
                    self.removeHelpFileNodes()
                    self.showFirstHelpFile()
                }
                else if self.helpFilePos == 1 {
                    self.removeHelpFileNodes()
                    self.showSecondHelpFile()
                }
                else if self.helpFilePos == 2 {
                    self.removeHelpFileNodes()
                    self.showKrazyKoalaAdInfo()
                }
                else if self.helpFilePos == 3 {
                    self.removeHelpFileNodes()
                    self.showThirdHelpFile()
                }
                else {
                    // go back to start menu
                    let startScene = StartScene(size: self.size, controller: self.controller)
                    startScene.scaleMode = .aspectFill
                    self.view?.presentScene(startScene)
                }
            }
            else {
                if nodeName == "KrazyKoala" {
                    self.openAppStore()
                }
            }
        }
    }
}
