//
//  GameViewController.swift
//  aaa
//
//  Created by Long Zhen on 3/30/16.
//  Copyright (c) 2016 Long Zhen. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
        
        startBackgroundMusic()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func startBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "bg", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: path) as URL, fileTypeHint: "mp3")
            } catch {
            }
            
            if let player = audioPlayer {
                player.prepareToPlay()
                player.numberOfLoops = -1
                player.play()
            }
        }
    }
}
