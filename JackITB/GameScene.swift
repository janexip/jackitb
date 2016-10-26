//
//  GameScene.swift
//  JackITB
//
//  Created by Xiaoxi Ip on 9/28/16.
//  Copyright (c) 2016 Xiaoxi Ip. All rights reserved.
//

import SpriteKit
import Foundation

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}


class GameScene: SKScene {
    var box = SKSpriteNode()
    var flower = SKSpriteNode()
    var ball = SKSpriteNode()
    var music = SKAudioNode()
    var stage = 0
    var musicIsOn = false
    var ballSelected = false
    
    let animals = ["bee","bat","squirrel"]
    
    override func didMoveToView(view: SKView) {
        
        //add splash screen
        let splashScreen = SKSpriteNode(imageNamed: "splash")
        splashScreen.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        splashScreen.zPosition = 20
        splashScreen.name = "splash"
        self.addChild(splashScreen)
        
        backgroundColor = SKColor(red: 255/255, green: 252/255, blue: 201/255, alpha: 1.0)
        
        //add box: create box atlas
        let boxAtlas = SKTextureAtlas(named: "box")
        
        box = SKSpriteNode(texture: boxAtlas.textureNamed("box-body"))
        /*  print(box.frame.size.width)
        print(box.frame.size.height)
        print(self.frame.size.width)
        print(self.frame.size.height)*/
        box.position = CGPoint(x:CGRectGetMidX(self.frame), y:self.frame.size.height/4)
        box.zPosition = 5
        box.name = "box"
        self.addChild(box)
        
        flower = SKSpriteNode(texture: boxAtlas.textureNamed("flower"))
        flower.position = CGPoint(x:-box.frame.size.width/4, y: box.frame.size.height/4)
        flower.zPosition = 10
        flower.name = "flower"
        box.addChild(flower)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        var touchedNode = self.nodeAtPoint(touchLocation)
        
        //if user touched on children, treat as they touched the parent (ball or box)
        let parentName:String? = touchedNode.parent?.name
        if(parentName != nil){
            if(parentName == "ball" || parentName == "box"){
                touchedNode = touchedNode.parent as! SKSpriteNode
            }
        }
        
        let nodeName = touchedNode.name
        
        if(nodeName == "splash"){
            touchedNode.removeFromParent()
        }
        
        if(nodeName == "box" && musicIsOn == false){
            stage++
            if(stage > 5){
                stage = 1
            }
            switch stage{
            case 1:
                musicBox()
                addBall()
                playMusic("song-1.m4a")
            case 2:
                musicBox()
                addNotes()
                playMusic("song-2.m4a")
            case 3:
                musicBox()
                addNotes()
                playMusic("song-3.m4a")
            case 4:
                musicBox()
                addBall()
                playMusic("song-4.m4a")
            case 5:
                musicIsOn = true
                removeBall()
            default: break
                
            }
        }
        
        if(nodeName == "ball" && musicIsOn == false){
            ballSelected = true
            teaseBall(touchLocation)
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        if(ballSelected == true){
            teaseBall(touchLocation)
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if(!musicIsOn){
            ball.removeAllActions()
            ballSelected = false
            //if ball has been dragged down, remove the ball
            if(ball.position.y > box.position.y && ball.position.y <= box.position.y + box.frame.size.height/2 + ball.size.height*1/4){
                removeBall()
            }else{
                //target y position for the ball is hiding 1/8 of the ball in the box
                ball.position = CGPoint(x:box.position.x, y:box.position.y + box.frame.size.height/2 + ball.size.height*3/8)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    func playMusic(musicName: String){
        let playAction = SKAction.playSoundFileNamed(musicName, waitForCompletion: true)
        let pauseAction = SKAction.runBlock(pauseMusic)
        runAction(SKAction.sequence([playAction,pauseAction]))
    }
    
    func pauseMusic(){
        musicIsOn = false
        box.removeAllActions()
        flower.removeAllActions()
    }
    
    func addBall(){
        ball = randAnimalBall()
        ball.name = "ball"
        ball.position = CGPoint(x:box.position.x, y:box.position.y + box.frame.size.height/2 - ball.size.height/2)
        ball.zPosition = -1
        self.addChild(ball)
        
        //target y position for the ball is hiding 1/8 of the ball in the box
        let targetY = box.position.y + box.size.height/2 + ball.size.height*3/8
        let upActionOne = SKAction.moveToY(targetY + ball.size.height/4, duration: 0.25)
        upActionOne.timingMode = .EaseOut
        let downActionOne = SKAction.moveToY(targetY - ball.size.height/4, duration: 0.25)
        downActionOne.timingMode = .EaseInEaseOut
        let upActionTwo = SKAction.moveToY(targetY + ball.size.height/8, duration: 0.25)
        upActionTwo.timingMode = .EaseInEaseOut
        let downActionTwo = SKAction.moveToY(targetY - ball.size.height/8, duration: 0.25)
        downActionTwo.timingMode = .EaseInEaseOut
        let upActionThree = SKAction.moveToY(targetY + ball.size.height/16, duration: 0.25)
        upActionThree.timingMode = .EaseInEaseOut
        let downActionThree = SKAction.moveToY(targetY - ball.size.height/16, duration: 0.25)
        downActionThree.timingMode = .EaseInEaseOut
        let upActionFour = SKAction.moveToY(targetY + ball.size.height/32, duration: 0.25)
        upActionFour.timingMode = .EaseInEaseOut
        let downActionFour = SKAction.moveToY(targetY - ball.size.height/32, duration: 0.25)
        downActionFour.timingMode = .EaseInEaseOut
        let actionFinal = SKAction.moveToY(targetY, duration: 0.25)
        actionFinal.timingMode = .EaseInEaseOut
        
        //  ball.runAction(upActionOne)
        ball.runAction(SKAction.sequence([upActionOne,downActionOne,upActionTwo,downActionTwo,upActionThree,downActionThree,upActionFour,actionFinal]))
        
        for child in ball.children as! [SKSpriteNode] {
            if((child.name?.containsString("eyes")) == true){
                //blink eyes every * seconds
                let eyes = child
                let newTextureAction = SKAction.setTexture(SKTexture(imageNamed: "global-blink"))
                let waitAction = SKAction.waitForDuration(0.15)
                let originalTextureAction = SKAction.setTexture(SKTexture(imageNamed: eyes.name!))
                //blink twice in a row
                let blinkEyeAction = SKAction.sequence([newTextureAction,waitAction, originalTextureAction,waitAction,newTextureAction,waitAction, originalTextureAction])
                let blinkEyeLoop = SKAction.repeatActionForever(SKAction.sequence([blinkEyeAction, SKAction.waitForDuration(5.0)]))
                //first wait for ball to show up, then loop through blinking eyes
                eyes.runAction(SKAction.sequence([SKAction.waitForDuration(2.5), blinkEyeLoop]))
            }else if((child.name?.containsString("wings")) == true){
                //scale wings every * seconds
                let wings = child
                let scaleDownAction = SKAction.scaleXBy(0.9, y: 1.0, duration: 0.5)
                let scaleUpAction = SKAction.scaleXBy(1/0.9, y: 1.0, duration: 0.5)
                
                let waitAction = SKAction.waitForDuration(0.15)
                let wingAction = SKAction.sequence([scaleDownAction,waitAction, scaleUpAction,waitAction,scaleDownAction,waitAction, scaleUpAction])
                let wingLoop = SKAction.repeatActionForever(SKAction.sequence([wingAction, SKAction.waitForDuration(3.0)]))
                //first wait for ball and eyes, then loop through wings
                wings.runAction(SKAction.sequence([SKAction.waitForDuration(3), wingLoop]))
                
            }
        }
        
    }
    
    func removeBall(){
        let dis = ball.frame.size.height/4
        let upAction = SKAction.moveByX(0, y: dis, duration: 0.2)
        upAction.timingMode = .EaseOut
        let waitAction = SKAction.waitForDuration(0.2)
        let downAction = SKAction.moveToY(box.frame.size.height - ball.size.height/2, duration: 0.15)
        downAction.timingMode = .EaseIn
        
        let removeAction = SKAction.removeFromParent()
        ball.runAction(SKAction.sequence([upAction,waitAction,downAction,removeAction]))
        
        let scaleUpAction = SKAction.scaleBy(1.05, duration: 0.3)
        let boxWaitAction = SKAction.waitForDuration(0.8)
        let scaleDownAction = SKAction.scaleBy(1/1.05, duration: 0.1)
        let shakeUpAction = SKAction.scaleBy(1.05, duration: 0.05)
        let shakeDownAction = SKAction.scaleBy(1/1.05, duration: 0.05)
        
        box.runAction(SKAction.sequence([scaleUpAction,boxWaitAction,scaleDownAction, SKAction.waitForDuration(0.5), shakeUpAction,shakeDownAction, shakeUpAction, shakeDownAction, SKAction.runBlock(pauseMusic)]))
        
    }
    
    func teaseBall(touchLocation: CGPoint){
        let xDist = (touchLocation.x - ball.position.x);
        let yDist = (touchLocation.y - ball.position.y);
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        
        if(distance < 1.5*ball.size.height/2){
            let newX = ball.position.x + (ball.position.x - touchLocation.x)
            let newY = ball.position.y + (ball.position.y - touchLocation.y)
            let newPos = keepBallInBoundary(CGPoint(x: newX, y: newY))
            let ballAction = SKAction.moveTo(newPos, duration: 0.4)
            ballAction.timingMode = .EaseOut
            ball.runAction(ballAction)
        }
    }
    
    func keepBallInBoundary(pos: CGPoint) -> CGPoint{
        var newX = pos.x
        var newY = pos.y
        if(pos.x > self.frame.size.width - ball.size.width/2){
            newX = self.frame.size.width - ball.size.width/2
        }
        if(pos.x < ball.size.width/2){
            newX = ball.size.width/2
        }
        if(pos.y > self.frame.size.height - ball.size.height/2){
            newY = self.frame.size.height - ball.size.height/2
        }
        if(pos.y < box.position.y + box.frame.size.height/2 + ball.size.height*1/4){
            newY = box.position.y + box.frame.size.height/2 + ball.size.height*1/4
        }
        return CGPoint(x: newX, y: newY)
    }
    
    func musicBox(){
        musicIsOn = true
        
        let scaleUpAction = SKAction.scaleBy(1.05, duration: 0.15)
        let waitAction = SKAction.waitForDuration(0.15)
        let scaleDownAction = SKAction.scaleBy(1/1.05, duration: 0.1)
        //bounce twice in a row
        let bounceAction = SKAction.sequence([scaleUpAction,waitAction, scaleDownAction,waitAction,scaleUpAction,waitAction, scaleDownAction])
        let bounceLoop = SKAction.sequence([bounceAction, SKAction.waitForDuration(0.5), bounceAction])
        box.runAction(bounceLoop)
        
        //rotate flower
        let rotateAction = SKAction.rotateByAngle(CGFloat(-M_PI/4.0), duration: 0.25)
        flower.runAction(SKAction.repeatActionForever(rotateAction))
    }
    
    func addNotes(){
        
        let notesAtlas = SKTextureAtlas(named: "notes")
        //find the biggest note for size reference
        let noteZero = SKSpriteNode(texture: notesAtlas.textureNamed("note-25"))
        let gridWidth = CGFloat((self.frame.size.width - noteZero.frame.size.width)/5)
        let gridHeight = CGFloat((self.frame.size.height - box.frame.size.height - noteZero.frame.size.height)/3)
        
        var notes = [SKSpriteNode]()
        for i in 1...5 {
            for j in 1...3 {
                let dice = String(arc4random_uniform(UInt32(25)) + 1)
                let note = SKSpriteNode(texture: notesAtlas.textureNamed("note-"+String(dice)))
                let scale = random(0.4, max: 0.8)
                note.xScale = scale
                note.yScale = scale
                let randomX = CGFloat(i-1) * gridWidth + random(0.2, max: 0.8)*gridWidth + note.frame.size.width
                let randomY = CGFloat(j-1) * gridHeight + random(0.2, max: 0.8)*gridHeight + box.frame.size.height + note.frame.size.height
                note.position = CGPoint(x:randomX, y:randomY)
                note.zPosition = -2
                
                note.alpha = 0.7
                notes.append(note)
            }
        }
        
        notes.shuffle()
        let subnotes = notes[0..<10]
        
        var noteActions = [SKAction]()
        for note in subnotes {
            let noteAction = SKAction.runBlock({
                // let note = notes[dice]
                self.addChild(note)
                let fadeInAction = SKAction.fadeInWithDuration(0.4)
                let waitAction = SKAction.waitForDuration(0.4)
                let fadeOutAction = SKAction.fadeOutWithDuration(0.8)
                note.runAction(SKAction.sequence([fadeInAction, waitAction, fadeOutAction, SKAction.removeFromParent()]))
            })
            noteActions.append(noteAction)
            noteActions.append(SKAction.waitForDuration(0.2))
        }
        
        runAction(SKAction.sequence(noteActions))
        
    }
    
    func randAnimalBall() -> SKSpriteNode{
        //default ball images
        var ballImg = ""
        var eyesImg = ""
        var wingsImg = ""
        var tailImg = ""
        
        // let dice = arc4random_uniform(UInt32(animals.count))
        let dice = 0
        switch dice{
        case 0:
            ballImg = "bee-body"
            eyesImg = "blue-eyes"
            wingsImg = "bee-wings"
        case 1:
            ballImg = "bat-body"
            eyesImg = "red-eyes"
            wingsImg = "bat-wings"
        case 2:
            ballImg = "squirrel-body"
            eyesImg = "brown-eyes"
            wingsImg = ""
            tailImg = "squirrel-tail"
        default: break
            
        }
        
        let ball = SKSpriteNode(imageNamed:ballImg)
        
        //add in eyes
        if(!eyesImg.isEmpty){
            let eyes = SKSpriteNode(imageNamed:eyesImg)
            eyes.name = eyesImg
            eyes.zPosition = 1
            //postion of the child is calculated by the parent's and child's anchor point
            eyes.position = CGPointMake(0, ball.frame.size.height/16)
            // eyes.size = CGSize(width: eyes.size.width, height: eyes.size.height)
            ball.addChild(eyes)
        }
        
        //add in wings
        if(!wingsImg.isEmpty){
            let wings = SKSpriteNode(imageNamed:wingsImg)
            wings.name = wingsImg
            wings.zPosition = -1
            ball.addChild(wings)
        }
        
        //add in tail
        if(!tailImg.isEmpty){
            let tail = SKSpriteNode(imageNamed:tailImg)
            tail.name = tailImg
            tail.zPosition = -1
            tail.position = CGPointMake(ball.frame.size.width/5, ball.frame.size.height/16)
            ball.addChild(tail)
        }
        
        return ball
        
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
