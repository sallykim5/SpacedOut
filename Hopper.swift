//
//  Hopper.swift
//  Hop It
//
//  Created by Sally Kim on 5/30/19.
//  Copyright © 2019 iOS Kids. All rights reserved.
//

import SpriteKit

class Hopper: SKSpriteNode {
    var velocity = CGPoint.zero
    var minimumY: CGFloat = 0.0
    var hopSpeed: CGFloat = 20.0
    var isOnGround = true
    
    func setupPhysicsBody() {
        if let hopperTexture = texture { //texture is optional property of SKSpriteNode
            physicsBody = SKPhysicsBody(texture: hopperTexture, size: size)
            
            physicsBody?.isDynamic = true //indicates that we want this obj to be moved by physics engine (gravity, collision, etc.)
            physicsBody?.density = 8.0 //density is how heavity something is for its size
            physicsBody?.allowsRotation = false //so that skater can tip over
            physicsBody?.angularDamping = 10.0 //angular damping is how much a physics body resists rotating (i.e. change if tips over too easily, etc.)
            
            physicsBody?.categoryBitMask = PhysicsCategory.hopper
            //physicsBody?.collisionBitMask = PhysicsCategory.spike //this tells SpriteKit that we want hopper to be affected by collisions with spikes
            physicsBody?.contactTestBitMask = PhysicsCategory.spike | PhysicsCategory.rocket //this tells SpriteKit that we want to know when the skater has contacted either of these types of objects
        }
    }

}
