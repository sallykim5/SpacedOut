//
//  GameScene.swift
//  Hop It
//
//  Created by Sally Kim on 5/30/19.
//  Copyright © 2019 iOS Kids. All rights reserved.
//

import SpriteKit
import GameplayKit

//this struct holds various physics categories, so we can define which obj
//types collide or have contact with each other
struct PhysicsCategory {
    static let hopper: UInt32 = 0x1 << 0 //UInt32 is a special type of unsigned 32-bit integer SpriteKit uses for physics categories; unsigned = integer must be positive or zero
    static let spike: UInt32 = 0x1 << 1
    static let rocket: UInt32 = 0x1 << 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //enum for y-position spawn points from bricks; ground bricks are low and upperplatform bricks are high
    enum SpikeLevel: CGFloat {
        case low = 100.0
        case mid = 300.0
        case high = 500.0
    }
    
    //this enum defines the states the game may be in; we would add a paused case if we needed to add pause button
    enum GameState {
        case notRunning
        case running
    }
    
    var spikes = [SKSpriteNode]() //array that holds all current spikes
    
    var rockets = [SKSpriteNode]()
    
    var spikeSize = CGSize.zero
    
    var spikeLevel = SpikeLevel.low
    
    var gameState = GameState.notRunning //current game state is tracked
    
    var scrollSpeed: CGFloat = 1.0
    let startingScrollSpeed: CGFloat = 1.0
    
    let gravitySpeed: CGFloat = 1.5
    
    //properites for score-tracking
    var score: Int = 0 //tracks current score
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0 //track how much time has passed in seconds; update label once a second has passed
    
    var lastUpdateTime: TimeInterval?
    
    //hopper is created here
    let hopper = Hopper(imageNamed: "hopper")
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0) //sets gravity of the world; vector is a speed combined with a direction
        physicsWorld.contactDelegate = self //set GameScene as contact delegate of physics world
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        hopper.setupPhysicsBody() //set up skater and add her to the scene
        addChild(hopper)
        
        //add a tap gesture recognizer to know when user tapped, pinched, etc. screen
        let tapMethod = #selector(GameScene.handleTap(tapGesture:)) //selector is a reference to name of method, tapMethod is a reference to the method handleTap
        //tell the tap gesture recognizer which method it should call when user taps on screen
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod) //target tells gesture recognizer what class selecter will be in; selector is method to call
        view.addGestureRecognizer(tapGesture) //must be added to the view or won't do anything
        
        //add menu overlay with "Tap to play" text instead of game starting right away
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4) //alpha sets how transparent something is on scale from 0.0 to 1.0
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0) //this would set anchor point in node's lower-left corner
        menuLayer.position = CGPoint(x: 0.0, y: 0.0) //menu layer would fit perfectly over scene
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Tap to play", score: nil)
        addChild(menuLayer)
    }
    
    func resetHopper() {
        
        //set hopper's starting position, zPosition, and minimum Y
        let hopperX = frame.midX / 2.0
        let hopperY = hopper.frame.height / 2.0 + frame.midY
        hopper.position = CGPoint(x: hopperX, y: hopperY)
        hopper.zPosition = 10
        hopper.minimumY = hopperY
        
        hopper.zRotation = 0.0 //sets skater's sprite zRotation back to 0.0 -> skater stands up straight in case she tipped over
        hopper.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0) //stand still again
        hopper.physicsBody?.angularVelocity = 0.0 //the physics body may still be rotating
    }
    
    func setupLabels() {
        
        //label that says "score" in the upper left
        
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "score")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left //this makes the label's text hug the left side so always lined up properly
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        //label that shows player's actual score
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel" //this simply gives me an easy way to ge ta reference to that particular label later in code; need this for when we update the text of the labels (change the score)
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        //label that says "high score" in the upper right
        
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "high score")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        //label that shows the player's actual highest score
        
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode { //finds child node of scene that has name "scoreLabel" (set this up in setupLabels())
            scoreLabel.text = String(format: "%04d", score) //%04d -> % means we will be inserting a variable, 04 specifies that we want string to always be four digits long, and d specifies that variable we're inserting is integer
        }
    }
    
    func updateHighScoreLabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    //when a new game is started, reset to starting conditions
    func startGame() {
        
        //when a new game is stated, reset to starting conditions
        
        gameState = .running
        
        resetHopper()
        
        score = 0
        
        scrollSpeed = startingScrollSpeed
        spikeLevel = .low //need this to start using brickLevel
        lastUpdateTime = nil
        
        for spike in spikes { //remove all spike spirtes from scene because spikes could be all over the place
            spike.removeFromParent()
        }
        
        spikes.removeAll(keepingCapacity: true) //then remove spike sprites from spikes array
        
        for rocket in rockets { //remove rocket sprites from rockets array
            removeRocket(rocket)
        }
    }
    
    func gameOver() {
        
        //when game ends, see if player got new high score
        
        gameState = .notRunning
        
        if score > highScore {
            highScore = score
            
            updateHighScoreLabelText()
        }
        
        //show "Game Over!" menu overlay
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint.zero
        menuLayer.position = CGPoint.zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Game Over!", score: score)
        addChild(menuLayer)
        
    }
    
    func spawnSpikes(atPosition position: CGPoint) -> SKSpriteNode {
        
        let spike = SKSpriteNode(imageNamed: "spike")
        spike.position = position
        spike.zPosition = 8
        addChild(spike)
        
        spikeSize = spike.size //update spikeSize with real spike size
        
        spikes.append(spike) //add new spike to array of spikes
        
        //set up spike's physics body
        let center = spike.centerRect.origin
        spike.physicsBody = SKPhysicsBody(rectangleOf: spike.size, center: center)
        spike.physicsBody?.affectedByGravity = false //don't want spike to fall thro bottom of screen
        
        spike.physicsBody?.categoryBitMask = PhysicsCategory.spike //this tells SpriteKit what type of object this body is
        spike.physicsBody?.collisionBitMask = 0 //this tells SpriteKit that spikes shouldn't collide with anything
        
        return spike
        
    }
    
    func spawnRocket(atPosition position: CGPoint) {
        //create rocket sprite and add it to scene
        let rocket = SKSpriteNode(imageNamed: "rocket")
        rocket.position = position
        rocket.zPosition = 9 //so that it'll be behind skater but in front of bricks
        addChild(rocket)
        
        rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size, center: rocket.centerRect.origin) //rocket needs to be added to physics simulation
        rocket.physicsBody?.categoryBitMask = PhysicsCategory.rocket //use categoryBitMask to inspect what came in contact with what
        rocket.physicsBody?.affectedByGravity = false
        
        rockets.append(rocket) //add new rocket to array of rockets
    }
    
    func removeRocket(_ rocket: SKSpriteNode) {
        
        rocket.removeFromParent() //remove from scene
        
        if let rocketIndex = rockets.index(of: rocket) { //index of where the rocket sprite is in array
            rockets.remove(at: rocketIndex)
        }
    }
    
    func updateSpikes(withScrollAmount currentScrollAmount: CGFloat) {
        var farthestRightSpikeX: CGFloat = 0.0
        
        for spike in spikes {
            let newX = spike.position.x - currentScrollAmount //newX represents a new spot little to the left of where spike currently is
            if newX < -spikeSize.width { //checks if newX would move spike offscreen
                spike.removeFromParent() //removes from scene
                if let spikeIndex = spikes.index(of: spike){
                    spikes.remove(at: spikeIndex)
                }
            } else { //dealing with spikes still onscreen
                spike.position = CGPoint(x: newX, y: spike.position.y) //for spike that is still onscreen, update its position
                if spike.position.x > farthestRightSpikeX { //update farthest-right position tracker
                    farthestRightSpikeX = spike.position.x
                }
            }
        }
        
        //a while loop to ensure our screen is always full of spikes
        while farthestRightSpikeX < frame.width {
            var spikeX = farthestRightSpikeX + spikeSize.width + 1.0 //determines new spike's x-position by adding on full spike's width to currest farthest right position + one point gap
            let spikeY = (spikeSize.height / 2.0) + spikeLevel.rawValue //when new spikes are spawned, y-position will be adjusted by the CGFloat raw values set up in SpikeLevel enum
            
            //every now and then, leave a gap the player must jump over
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 50 { //50% change that we will leave a gap between spikes
                let gap = 20.0 * scrollSpeed //as hopper's speed increases, gap gets bigger
                spikeX += gap * 3
                
                //at each gap, add a gem
                let randomRocketYAmount = CGFloat(arc4random_uniform(150)) //random y-position for new rocket
                let newRocketY = spikeY + hopper.size.height + randomRocketYAmount //give us y-position for rocket that is up above where skater is so player has to jump to reach it
                let newRocketX = spikeX - gap / 2.0 //places rocket in middle of gap
                
                spawnRocket(atPosition: CGPoint(x: newRocketX, y: newRocketY))
            }
            
            if randomNumber < 30 {
                spikeLevel = .low
            }
            else if randomNumber < 60 {
                spikeLevel = .mid
            }
            else if randomNumber < 100 {
                spikeLevel = .high
            }
            
            //spawn new spike and update rightmost spike
            let newSpike = spawnSpikes(atPosition: CGPoint(x: spikeX, y: spikeY))
            farthestRightSpikeX = newSpike.position.x
        }
    }
    
    func updateRockets(withScrollAmount currentScrollAmount: CGFloat) {
        
        for rocket in rockets {
            
            //update each rocket's position
            let thisRocketX = rocket.position.x - currentScrollAmount
            rocket.position = CGPoint(x: thisRocketX, y: rocket.position.y) //will make rocket sprite move to the left at the same speed as the spikes
            
            //remove any rockets that have moved offscreen
            if rocket.position.x < 0.0 {
                
                removeRocket(rocket)
            }
        }
    }
    
    func updateHopper() { //every update frame will check if hopper has gone off screen
        
        //determine if hopper is currently at center
        if let velocityY = hopper.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 { //when hopper is moving, her physics body will have large velocity -> makes it so that it cannot hop twice in a row
                hopper.isOnGround = false
            }
        }
        
        //check if game should end
        let isOffScreen = hopper.position.y < 0.0 || hopper.position.x < 0.0 || hopper.position.y > frame.height || hopper.position.x > frame.width //checks if hopper falls off bottom of screen or pushed off the left side of screen
        
        
        if isOffScreen {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        //the player's score increases the longer they survive
        //only update score every 1 second
        
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 { //if more that one second has elapsed then we increase player's score
            
            //increase score
            score += Int(scrollSpeed)
            
            //reset lastScoreUpdateTime to current time
            lastScoreUpdateTime = currentTime //this way, next time we calculate elapsed time, we'll be able to check if one scecond has passed since current time
            
            updateScoreLabelText()
        }
    }
    
    override func update(_ currentTime: TimeInterval) { // Called before each frame is rendered
        if gameState != .running {
            return //to make game updates stop when game is over
        }
        
        //slowly increase scrollSpeed as game progresses
        scrollSpeed += 0.01
        
        //determine elapsed time since last update call
        var elapsedTime: TimeInterval = 0.0 //TimeInterval (Double) tracks time intervals in seconds
        
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp //how much time has passed since last update call
        }
        
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0 //about 1/60 of a sec should pass between each call to update(_:)
        
        //here we calculate how far everything should move in this update
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime) //i.e. if more time has passed than expected (> 1/60 of a sec), this factor will be greater than 1.0
        let currentScrollAmount = scrollSpeed * scrollAdjustment //determines what scroll speed should be for this update using adjustment factor
        
        updateSpikes(withScrollAmount: currentScrollAmount)
        
        updateHopper()
        
        updateRockets(withScrollAmount: currentScrollAmount)
        
        updateScore(withCurrentTime: currentTime)
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer){
        
        if gameState == .running {
            //make hopper jump if player taps while hopper is at center
            hopper.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 50.0)) //apply impulse force to hopper sprite's physics body
        } else {
            
            //if game is not running, tapping starts new game
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode { //getting reference to menu layer by asking scene for its child node by name
                
                menuLayer.removeFromParent() //this will make menu disappear
            }

            startGame()
        }
        
    
    }
    
    //didBegin() everytime we add SKPhysicsContactDelegate protocol
    func didBegin(_ contact: SKPhysicsContact) { //method that will be called whenever two physics bodies come into contact with each other
        if contact.bodyA.categoryBitMask == PhysicsCategory.hopper && contact.bodyB.categoryBitMask == PhysicsCategory.spike {
            hopper.isOnGround = true
            gameOver()
        }
        
        else if contact.bodyA.categoryBitMask == PhysicsCategory.hopper && contact.bodyB.categoryBitMask == PhysicsCategory.rocket {
            
            if let rocket = contact.bodyB.node as? SKSpriteNode { //gives us reference to rocket spirte by downcasting node to an SKSpriteNode
                removeRocket(rocket)
                
                //give the player 50 points for getting a rocket
                score += 50
                updateScoreLabelText()
            }
        }
        
    }
}
