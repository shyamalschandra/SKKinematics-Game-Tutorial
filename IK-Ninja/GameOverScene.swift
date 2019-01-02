//
//  GameOverScene.swift
//  IK-Ninja
//
//  Created by Long Zhen on 3/30/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    override func didMove(to view: SKView) {
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Game Over"
        myLabel.fontSize = 65
        myLabel.position = CGPoint(x:frame.midX, y:frame.midY)
        addChild(myLabel)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run({
                let transition = SKTransition.fade(withDuration: 1.0)
                let scene = GameScene(fileNamed:"GameScene")
                let skView = self.view!
                scene!.scaleMode = .aspectFill
                scene!.size = skView.bounds.size
                self.view?.presentScene(scene!, transition: transition)
            })]))
    }
}
