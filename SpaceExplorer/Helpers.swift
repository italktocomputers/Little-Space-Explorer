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

import Foundation
import SpriteKit

class Helpers {
    func createLabel(text: String, fontSize: CGFloat, position: CGPoint, name:String="", color:SKColor=SKColor.white, font:String="KohinoorDevanagari-Medium", zPos:CGFloat=100) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: font)
        label.text = text
        label.fontColor = color
        label.fontSize = fontSize
        label.position = position
        label.zPosition = zPos
        
        if name == "" {
            label.name = text
        }
        else {
            label.name = name
        }
        
        return label
    }
    
    func removeNodeByName(scene: SKScene, name: String) {
        scene.enumerateChildNodes(
            withName: name,
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
    }
    
    func getDifficultyIndex(difficulty: String) -> String {
        if difficulty == "easy" {
            return ""
        }
        else if difficulty == "medium" {
            return "2"
        }
        else {
            return "3"
        }
    }
    
    func saveHighScore(score: Int, difficulty: String) {
        let key = "highScore" + self.getDifficultyIndex(difficulty: difficulty)
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: key)
        defaults.synchronize()
    }
    
    func saveLastScore(score: Int, difficulty: String) {
        let key = "lastScore" + self.getDifficultyIndex(difficulty: difficulty)
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: key)
        defaults.synchronize()
    }
    
    func getHighScore(difficulty: String) -> Int {
        let key = "highScore" + self.getDifficultyIndex(difficulty: difficulty)
        let defaults = UserDefaults.standard
        return defaults.integer(forKey:key)
    }
    
    func getLastScore(difficulty: String) -> Int {
        let key = "lastScore" + self.getDifficultyIndex(difficulty: difficulty)
        let defaults = UserDefaults.standard
        return defaults.integer(forKey:key)
    }
    
    func clearStats() {
        let defaults = UserDefaults.standard
        
        defaults.set(0, forKey: "highScore1")
        defaults.set(0, forKey: "highScore2")
        defaults.set(0, forKey: "highScore3")
        
        defaults.set(0, forKey: "lastScore1")
        defaults.set(0, forKey: "lastScore2")
        defaults.set(0, forKey: "lastScore3")
        
        defaults.synchronize()
    }
}
