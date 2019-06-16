//
//  MenuLayer.swift
//  Spaced 0ut
//
//  Created by Sally Kim on 6/1/19.
//  Copyright © 2019 iOS Kids. All rights reserved.
//

import SpriteKit

class MenuLayer: SKSpriteNode {
    
    //tells MenuLayer to display a message and to optionally display a score
    func display(message: String, score: Int?) {
        
        //create a message label using passed-in message
        let messageLabel: SKLabelNode = SKLabelNode(text: message)
        
        //set label's satrting position to the left of menu layer
        let messageX = -frame.width //-frame.width as x-position to set label one full screen's width to the left
        let messageY = frame.height / 2.0 //center of frame
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        self.addChild(messageLabel)
        
        //adnimate message label to center of screen
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3) //moveTo to move a node to new x-position
        messageLabel.run(messageAction) //this tells message label to run this action (actions you create describe what  node should do but nothign will happen until you tell node to run that action)
        
        //if a score was passed in to the method, display it
        if let scoreToDisplay = score {
            //create score text from the score Int
            let scoreString = String(format: "Score: %04d", scoreToDisplay)
            let scoreLabel: SKLabelNode = SKLabelNode(text: scoreString)
            
            //set label's starting position to the right of menu layer
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Courier-Bold"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            
            //animate score label to center of screen
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }
}
