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

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate {
    var iAdError = false
    //var adBannerView: ADBannerView?
    var isLoadingiAd = false
    var currentSceneName: String = ""
    
    /*
    func loadAds() {
        self.isLoadingiAd = true
        
        let adBannerView = ADBannerView()
        adBannerView.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        adBannerView.delegate = self
        adBannerView.isHidden = true
        view.addSubview(adBannerView)
        
        self.adBannerView = adBannerView
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.loadAds()
        //self.adBannerView?.isHidden = true
        
        // Configure the view.
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        
        // Sprite Kit applies additional optimizations to improve rendering performance
        skView.ignoresSiblingOrder = true
        
        let size = CGSize(width: 1024, height: 768)
        let scene = StartScene(size: size, controller: self)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /*
    //iAd
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        //println("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //println("bannerViewDidLoadAd")
        
        self.iAdError = false
        self.isLoadingiAd = false
        
        if currentSceneName != "GameScene" {
            banner.isHidden = false
        }
        else {
            banner.isHidden = true // no iAds during game play
        }
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView) {
        //println("bannerViewActionDidFinish")
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView, willLeaveApplication willLeave: Bool) -> Bool {
        //println("bannerViewActionShouldBegin")
        return true 
    }
    
    func bannerView(_ banner: ADBannerView, didFailToReceiveAdWithError error: Error) {
        //println("iAd error")
        
        banner.isHidden = true
        banner.removeFromSuperview()
        self.iAdError = true
        self.isLoadingiAd = false
    }
    */
}
