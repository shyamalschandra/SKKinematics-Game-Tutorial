//
//  GameScene.swift
//  IK-Ninja
//
//  Created by Ken Toh on 7/9/14.
//  Copyright (c) 2014 Ken Toh. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //1
    // shadow node
    var shadow: SKNode!
    // root node the ninja body
    var lowerTorso: SKNode!
    
    // nodes of ninja upper body parts
    var upperTorso: SKNode!
    var upperArmFront: SKNode!
    var lowerArmFront: SKNode!
    var fistFront: SKNode!
    // front & back
    var upperArmBack: SKNode!
    var lowerArmBack: SKNode!
    var fistBack: SKNode!
    
    // head node with its target
    var head: SKNode!
    let targetNode = SKNode()
    
    // the kicking leg 
    var upperLeg: SKNode!
    var lowerLeg: SKNode!
    var foot: SKNode!
    
    // ninja rest status parameters
    let upperArmAngleDeg: CGFloat = -10
    let lowerArmAngleDeg: CGFloat = 130
    // leg rest status 
    let upperLegAngleDeg: CGFloat = 22
    let lowerLegAngleDeg: CGFloat = -30
    
    // flag to alternate which fist punches
    var rightPunch = true
    // first user tap input flag
    var firstTouch = false
    
    // parameter to control shuriken generation
    var lastSpawnTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    // last part! gaming score 
    var score: Int = 0
    var life: Int = 3
    let scoreLabel = SKLabelNode()
    let livesLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        // set the UI with score information 
        // setup score label
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        scoreLabel.position = CGPoint(x: 10, y: size.height -  10)
        addChild(scoreLabel)
        
        // setup lives label
        livesLabel.fontName = "Chalkduster"
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 20
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        livesLabel.position = CGPoint(x: size.width - 10, y: size.height - 10)
        addChild(livesLabel)
        
        //2
        lowerTorso = childNode(withName: "torso_lower")
        lowerTorso.position = CGPoint(x: frame.midX, y: frame.midY - 30)
        
        //3
        shadow  = childNode(withName: "shadow")
        shadow.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        
        upperTorso = lowerTorso.childNode(withName: "torso_upper")
        upperArmFront = upperTorso.childNode(withName: "arm_upper_front")
        lowerArmFront = upperArmFront.childNode(withName: "arm_lower_front")
        fistFront = lowerArmFront.childNode(withName: "fist_front")
        
        upperArmBack = upperTorso.childNode(withName: "arm_upper_back")
        lowerArmBack = upperArmBack.childNode(withName: "arm_lower_back")
        fistBack = lowerArmBack.childNode(withName: "fist_back")
        
        upperLeg = lowerTorso.childNode(withName: "leg_upper_back")
        lowerLeg = upperLeg.childNode(withName: "leg_lower_back")
        foot = lowerLeg.childNode(withName: "foot_back")
        
        lowerLeg.reachConstraints = SKReachConstraints(lowerAngleLimit: CGFloat(-45).degreesToRadians(), upperAngleLimit: 0)
        upperLeg.reachConstraints = SKReachConstraints(lowerAngleLimit: CGFloat(-45).degreesToRadians(), upperAngleLimit: CGFloat(160).degreesToRadians())
        
        // constraints that prevent ninja from bending arm unnaturally
        let range = SKRange(lowerLimit: CGFloat(0).degreesToRadians(),
                            upperLimit: CGFloat(160).degreesToRadians())
        let rotationConstraint = SKConstraint.zRotation(range)
        lowerArmFront.constraints = [rotationConstraint]
        lowerArmBack.constraints = [rotationConstraint]
        
        head = upperTorso.childNode(withName: "head")
        // 1
        let orientToNodeConstraint = SKConstraint.orient(to: targetNode, offset: SKRange(constantValue: 0.0))
        // 2
        let rangeOfHead = SKRange(lowerLimit: CGFloat(-50).degreesToRadians(),
                            upperLimit: CGFloat(80).degreesToRadians())
        // 3
        let rotationConstraintOfHead = SKConstraint.zRotation(rangeOfHead)
        // 4
        // disable because at the very beginning there is no target
        rotationConstraint.enabled = false
        orientToNodeConstraint.enabled = false
        // 5
        head.constraints = [orientToNodeConstraint, rotationConstraintOfHead]
        
    }
    
//    naive test implementation
//    func punchAtLocation(location: CGPoint) {
//        // 1
//        let punch = SKAction.reachTo(location, rootNode: upperArmFront, duration: 0.1)
//        // 2
//        // lowerArmFront.runAction(punch)
//        fistFront.runAction(punch)
//    }
//    ===================================================
//    only front arm punch version
//    func punchAtLocation(location: CGPoint) {
//        // 1
//        let punch = SKAction.reachTo(location, rootNode: upperArmFront, duration: 0.1)
//        
//        // 2
//        let restore = SKAction.runBlock {
//            self.upperArmFront.runAction(SKAction.rotateToAngle(self.upperArmAngleDeg.degreesToRadians(), duration: 0.1))
//            self.lowerArmFront.runAction(SKAction.rotateToAngle(self.lowerArmAngleDeg.degreesToRadians(), duration: 0.1))
//        }
//        
//        // 3
//        fistFront.runAction(SKAction.sequence([punch, restore]))
//    }
    // 1
    func punchAtLocation(location: CGPoint, upperArmNode: SKNode, lowerArmNode: SKNode, fistNode: SKNode) {
        let punch = SKAction.reach(to: location, rootNode: upperArmNode, duration: 0.1)
        let restore = SKAction.run {
            upperArmNode.run(SKAction.rotate(toAngle: self.upperArmAngleDeg.degreesToRadians(), duration: 0.1))
            lowerArmNode.run(SKAction.rotate(toAngle: self.lowerArmAngleDeg.degreesToRadians(), duration: 0.1))
        }
        
        // fistNode.runAction(SKAction.sequence([punch, restore]))
        let checkIntersection = intersectionCheckActionForNode(effectorNode: fistNode)
        fistNode.run(SKAction.sequence([punch, checkIntersection, restore]))
    }
    
    func punchAtLocation(location: CGPoint) {
        // 2
        if rightPunch {
            punchAtLocation(location: location, upperArmNode: upperArmFront, lowerArmNode: lowerArmFront, fistNode: fistFront)
        }
        else {
            punchAtLocation(location: location, upperArmNode: upperArmBack, lowerArmNode: lowerArmBack, fistNode: fistBack)
        }
        // 3
        rightPunch = !rightPunch
    }
    
    // leg kick operation
    func kickAtLocation(location: CGPoint) {
        let kick = SKAction.reach(to: location, rootNode: upperLeg, duration: 0.1)
        
        let restore = SKAction.run {
            self.upperLeg.run(SKAction.rotate(toAngle: self.upperLegAngleDeg.degreesToRadians(), duration: 0.1))
            self.lowerLeg.run(SKAction.rotate(toAngle: self.lowerLegAngleDeg.degreesToRadians(), duration: 0.1))
        }
        
        let checkIntersection = intersectionCheckActionForNode(effectorNode: foot)
        
        foot.run(SKAction.sequence([kick, checkIntersection, restore]))
    }
    
    // 3
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // start constraints for head
        if !firstTouch {
            for c in head.constraints! {
                // var constraint = c as! SKConstraint
                // meaningless statement
                c.enabled = true
            }
            firstTouch = true
        }
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            lowerTorso.xScale =
                location.x < frame.midX ? abs(lowerTorso.xScale) * -1 : abs(lowerTorso.xScale)
            // punchAtLocation(location)
            // instead of simple punch, here deal with punching(fist) & kick(foot)
            let lower = location.y < lowerTorso.position.y + 10
            if lower {
                kickAtLocation(location: location)
            }
            else {
                punchAtLocation(location: location)
            }
            targetNode.position = location
        }
    }
    
    // add flying shurikens
    func addShuriken() {
        // 1
        let shuriken = SKSpriteNode(imageNamed: "projectile")
        // 2
        let minY = lowerTorso.position.y - 60 + shuriken.size.height/2
        let maxY = lowerTorso.position.y  + 140 - shuriken.size.height/2
        let rangeY = maxY - minY
        let actualY = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeY)) + minY
        // 3
        let left = arc4random() % 2
        let actualX = (left == 0) ? -shuriken.size.width/2 : size.width + shuriken.size.width/2
        // 4
        shuriken.position = CGPoint(x: actualX, y: actualY)
        shuriken.name = "shuriken"
        shuriken.zPosition = 1
        addChild(shuriken)
        // 5
        let minDuration = 4.0
        let maxDuration = 6.0
        let rangeDuration = maxDuration - minDuration
        let actualDuration = (Double(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        // 6
        let actionMove = SKAction.move(to: CGPoint(x: size.width/2, y: actualY), duration: actualDuration)
        let actionMoveDone = SKAction.removeFromParent()
        // new action: shuriken kit ninja, life point decrease
        let hitAction = SKAction.run({
            // 1
            if self.life > 0 {
                self.life -= 1
            }
            // 2
            self.livesLabel.text = "Lives: \(Int(self.life))"
            
            // 3
            let blink = SKAction.sequence([SKAction.fadeOut(withDuration: 0.05), SKAction.fadeIn(withDuration: 0.05)])
            
            // 4
            let checkGameOverAction = SKAction.run({
                if self.life <= 0 {
                    let transition = SKTransition.fade(withDuration: 1.0)
                    let skView = self.view! as SKView
                    let gameOverScene = GameOverScene(size: skView.bounds.size)
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            })
            // 5
            self.lowerTorso.run(SKAction.sequence([blink, blink, checkGameOverAction]))
        })
        
        // new action for shuriken hit ninja
        shuriken.run(SKAction.sequence([actionMove, hitAction, actionMoveDone]))
        // shuriken.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        // 7
        let angle = left == 0 ? CGFloat(-90).degreesToRadians() : CGFloat(90).degreesToRadians()
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: angle, duration: 0.2))
        shuriken.run(SKAction.repeatForever(rotate))
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval) {
        lastSpawnTimeInterval = timeSinceLast + lastSpawnTimeInterval
        if lastSpawnTimeInterval > 0.75 {
            lastSpawnTimeInterval = 0
            addShuriken()
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if timeSinceLast > 1.0 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLast: timeSinceLast)
    }
    
    func intersectionCheckActionForNode(effectorNode: SKNode) -> SKAction {
        let checkIntersection = SKAction.run {
            
            for object: AnyObject in self.children {
                // check for intersection against any sprites named "shuriken"
                if let node = object as? SKSpriteNode {
                    if node.name == "shuriken" {
                        //convert coordinates into common system based on root node
                        let effectorInNode = self.convert(effectorNode.position, from:effectorNode.parent!)
                        var shurikenFrame = node.frame
                        shurikenFrame.origin = self.convert(shurikenFrame.origin, from: node.parent!)
                        
                        if shurikenFrame.contains(effectorInNode) {
                        // if node.intersectsNode(effectorNode) {
                            // play a hit sound
                            self.run(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
                            
                            // show a spark effect
                            let spark = SKSpriteNode(imageNamed: "spark")
                            spark.position = node.position
                            spark.zPosition = 60
                            self.addChild(spark)
                            let fadeAndScaleAction = SKAction.group([
                                SKAction.fadeOut(withDuration: 0.2),
                                SKAction.scale(to: 0.1, duration: 0.2)])
                            let cleanUpAction = SKAction.removeFromParent()
                            spark.run(SKAction.sequence([fadeAndScaleAction, cleanUpAction]))
                            
                            self.score += 1
                            self.scoreLabel.text = "Score: \(Int(self.score))"
                            // remove the shuriken
                            node.removeFromParent()
                        }
                        else {
                            // play a miss sound
                            self.run(SKAction.playSoundFileNamed("miss.mp3", waitForCompletion: false))
                        }
                    }
                }
            }
        }
        return checkIntersection
    }

}
