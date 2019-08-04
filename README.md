<p align="center"> 
<img src="https://github.com/sallykim5/Spaced0ut/blob/master/space@3x.png?raw=true" width="300" height="300" />
</p>

# Spaced Out

> An iOS game created in the style of Flappy Bird. The player controls an astronaut whose goal is to dodge incoming spike balls and collect rockets for points.

**This is what the start screen looks like**

<img src="https://github.com/sallykim5/Spaced0ut/blob/master/Simulator%20Screen%20Shot%20-%20iPhone%207%20-%202019-06-11%20at%2010.33.59.png" width="300" height="500" />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**This is what the environment looks like**

<img src="https://github.com/sallykim5/Spaced0ut/blob/master/Simulator%20Screen%20Shot%20-%20iPhone%207%20-%202019-06-11%20at%2010.35.48.png" width="300" height="500" />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**This is the "Game Over" screen that loads once the player hits a spike ball**

<img src="https://github.com/sallykim5/Spaced0ut/blob/master/Simulator%20Screen%20Shot%20-%20iPhone%208%20-%202019-06-11%20at%2021.06.45.png" width="300" height="500" />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

# How it works in action!

**Player loads the start screen and repeatedly taps the screen to move the astronaut**

![Recordit GIF](http://g.recordit.co/H3JTn9KLhv.gif)
- The more rockets the player collects and the longer the player survives, the more points he or she will have
- As the player collects more rockets, the speed of the astronaut will increase

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**Once the player hits a spike ball, the game is over**

![Recordit GIF](http://g.recordit.co/CPDW3oj5FY.gif)
- The highscore is displayed on the screen 

---

## How do the objects in the game interact?

**Code #1**

```swift
if let hopperTexture = texture { //texture is optional property of SKSpriteNode
    physicsBody = SKPhysicsBody(texture: hopperTexture, size: size)
    
    physicsBody?.isDynamic = true //indicates that we want this obj to be moved by physics engine (gravity, collision, etc.)
    physicsBody?.density = 8.0 //density is how heavity something is for its size
    physicsBody?.allowsRotation = false //so that astronaut does not tip over
    physicsBody?.angularDamping = 10.0 //angular damping is how much a physics body resists rotating (i.e. change if tips over too easily, etc.)
            
    physicsBody?.categoryBitMask = PhysicsCategory.hopper
    physicsBody?.contactTestBitMask = PhysicsCategory.spike | PhysicsCategory.rocket //this tells SpriteKit that we want to know when the skater has contacted either of these types of objects
}

```
- This is the code that was written to create the physics body of the astronaut. I experimented many times with the density and angular damping of the astronaut because I wanted the player to interact with the astronaut and feel as though the astronaut was really in space.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**Code #2**

```swift
hopper.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 50.0)) //apply impulse force to hopper sprite's physics body
```
- This was written in the GameScene.swift to indicate how the astronaut would be impacted if the player tapped on the screen. 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**Code #3**

```swift 
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
```
- A physics body was given to both the spike and the rocket. This code indicates what happens when the astronaut's physics body comes in contact with the rocket physics body or the spike physics body.

---

## How is the player challenged? 
```swift
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
        
 ```
 - By tracking the duration of the game, I can increase the speed of the game as time passes. The player also earns points for staying alive (but not as much as he or she would by collecting rockets).

---

## FAQ

- **Who is the programmer behind all this?**

<p align="center"> 
<img src="https://github.com/sallykim5/personal/blob/master/profpic.png" width="200" height="150" />
</p>
    - Hello! My name is Sally, and I am a rising senior at Emory University. I have a passion for developing creative code and implementing it in real-life applications. I take my passion and have fun with it.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

- **How did I learn the skills to program this fun game?**
    - I read "Coding iPhone Apps for Kids" by Gloria Winquist and Matt McCarthy and watched tutorials on YouTube!
---

## Support

Reach out to me at one of the following places!

- Linkedin at <a href="https://www.linkedin.com/in/sallykim5">
- Facebook at <a href="https://www.facebook.com/sally.kim425">
