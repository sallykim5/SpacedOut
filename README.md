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

**This is the "Game Over" screen that loads once the players 
<img src="https://github.com/sallykim5/Spaced0ut/blob/master/Simulator%20Screen%20Shot%20-%20iPhone%208%20-%202019-06-11%20at%2021.06.45.png" width="300" height="500" />

- This is the "Game Over" screen that loads once the player hits a spike ball 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

# How it works in action!

**Player loads the start screen and repeatedly taps the screen to move the astronaut**

![Recordit GIF](http://g.recordit.co/H3JTn9KLhv.gif)
- The more rockets the player collects, the more points he/she will have
- As the player collects more rockets, the speed of the astronaut and the value of each rocket will increase

**Once the player hits a spike ball, the game is over**

![Recordit GIF](http://g.recordit.co/CPDW3oj5FY.gif)
- The highscore is displayed on the screen 

---

## Example Code

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

```javascript 
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

## FAQ

- **How did I learn the skills to program this fun game?*
    - I read "Coding iPhone Apps for Kids" by Gloria Winquist and Matt McCarthy and watched tutorials on YouTube!
---

## Support

Reach out to me at one of the following places!

- Linkedin at <a href="www.linkedin.com/in/sallykim5">
- Facebook at <a href="https://www.facebook.com/sally.kim425">
