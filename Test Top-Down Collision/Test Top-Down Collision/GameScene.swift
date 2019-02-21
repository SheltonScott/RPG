//
//  GameScene.swift
//  Test Top-Down Collision
//
//  Created by scott shelton on 11/28/18.
//  Copyright © 2018 scott shelton. All rights reserved.
//

import SpriteKit
import GameplayKit

class Player {
    var level = 1
    var health = 100
    var maxHealth = 100
    var exp = 0
    var bonus = 1
    
    func doDamage()->Int {
        let damage = Int(arc4random_uniform(8)) + bonus
        return damage
    }
    
    func didLevelUp()->Bool {
        if exp >= 5 && exp < 10 {
            return true
        }
        if exp >= 10 && exp < 15 {
            return true
        }
        if exp >= 15 && exp < 20 {
            return true
        }
        if exp >= 20 && exp < 25 {
            return true
        }
        return false
    }
    
    func levelUp() {
        if didLevelUp() {
            level += 1
            maxHealth += Int(arc4random_uniform(6) + 1)
            bonus += 1
            health = maxHealth
        }
    }
}

class Enemy {
    var health = 10
    let exp = 5
    
    func doDamage()->Int {
        let damage = Int(arc4random_uniform(6)) + 1
        return damage
    }
}

class Boss {
    var health = 50
    let exp = 10
    
    func doDamage()->Int {
        let damage = Int(arc4random_uniform(12)) + 1
        return damage
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let node1 = SKSpriteNode(color: UIColor.purple, size: CGSize(width: 96, height: 100))
    let player = Player()
    let playerMaxHealthLabel = SKLabelNode()
    let playerHealthLabel = SKLabelNode()
    let playerLevelLabel = SKLabelNode()
    let playerExpLabel = SKLabelNode()
    let playerBonusLabel = SKLabelNode()
    
    let maxHealthNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 96, height: 100))
    let healthNode = SKSpriteNode(color: UIColor.red, size: CGSize(width: 96, height: 100))
    
    let node2 = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 96, height: 100))
    let boss = Boss()
    let bossHealthLabel = SKLabelNode()
    
    let node3 = SKSpriteNode(color: UIColor.brown, size: CGSize(width: 96, height: 100))
    let enemy = Enemy()
    let enemyHealthLabel = SKLabelNode()
    
    let key = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 48, height: 50))
    
    let upArrow = SKSpriteNode(imageNamed: "jump-arrow")
    let downArrow = SKSpriteNode(imageNamed: "down-arrow")
    let leftArrow = SKSpriteNode(imageNamed: "left-arrow")
    let rightArrow = SKSpriteNode(imageNamed: "right-arrow")
    
    let cam = SKCameraNode()
    
    let Node1Category : UInt32 = 0x1 << 1
    let CliffCategory : UInt32 = 0x1 << 2
    let WaterCategory : UInt32 = 0x1 << 3
    let Node2Category : UInt32 = 0x1 << 4
    let Node3Category : UInt32 = 0x1 << 5
    
    var movementSpeed = 0.5
    var firstContact = false
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        self.camera = cam
        self.addChild(cam)
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: node1)
        cam.constraints = [constraint]
        
        for node in self.children {
            if (node.name == "Cliff Tile Map Node") {
                if let someTileMap:SKTileMapNode = node as? SKTileMapNode {
                    giveTileMapPhysicsBody(map: someTileMap, name: "cliff")
                    someTileMap.removeFromParent()
                }
            }
        }
        
        for node in self.children {
            if (node.name == "Water Tile Map Node") {
                if let someTileMap:SKTileMapNode = node as? SKTileMapNode {
                    giveTileMapPhysicsBody(map: someTileMap, name: "water")
                    someTileMap.removeFromParent()
                }
            }
        }
        
        node1.position = CGPoint(x: frame.midX + 100, y: frame.midY + 100)
        node1.zPosition = 1
        node1.physicsBody = SKPhysicsBody(rectangleOf: node1.size)
        node1.physicsBody?.allowsRotation = false
        node1.physicsBody?.affectedByGravity = false
        node1.physicsBody?.categoryBitMask = Node1Category
        node1.physicsBody?.collisionBitMask = CliffCategory | Node2Category | Node3Category
        node1.physicsBody?.contactTestBitMask = WaterCategory | Node2Category | Node3Category
        node1.name = "node1"
        addChild(node1)
        
        node2.position = CGPoint(x: frame.midX - 100, y: frame.midY - 100)
        node2.physicsBody = SKPhysicsBody(rectangleOf: node2.size)
        node2.physicsBody?.allowsRotation = false
        node2.physicsBody?.affectedByGravity = false
        node2.physicsBody?.categoryBitMask = Node2Category
        node2.physicsBody?.collisionBitMask = Node1Category | Node3Category | CliffCategory
        node2.physicsBody?.contactTestBitMask = Node1Category
        node2.name = "node2"
        addChild(node2)
        
        let square = UIBezierPath(rect: CGRect(x: 0,y: 0, width: 100, height: 100))
        let followSquare = SKAction.follow(square.cgPath, asOffset: true, orientToPath: false, duration: 5)
        
        node2.run(SKAction.repeatForever(followSquare))
        
        node3.position = CGPoint(x: frame.midX - 100, y: frame.midY - 300)
        node3.physicsBody = SKPhysicsBody(rectangleOf: node3.size)
        node3.physicsBody?.allowsRotation = false
        node3.physicsBody?.affectedByGravity = false
        node3.physicsBody?.categoryBitMask = Node3Category
        node3.physicsBody?.collisionBitMask = Node1Category | Node2Category | CliffCategory
        node3.physicsBody?.contactTestBitMask = Node1Category
        node3.name = "node3"
        addChild(node3)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 50, y: 100))
        let followLine = SKAction.follow(path, speed: 30)
        
        let reversedLine = followLine.reversed()
        
        node3.run(SKAction.repeatForever(SKAction.sequence([followLine,reversedLine])))
        
        upArrow.position = CGPoint(x: frame.midX, y: frame.minY + 250)
        upArrow.zPosition = 1
        downArrow.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        downArrow.zPosition = 1
        leftArrow.position = CGPoint(x: frame.midX - 150, y: frame.minY + 100)
        leftArrow.zPosition = 1
        rightArrow.position = CGPoint(x: frame.midX + 150, y: frame.minY + 100)
        rightArrow.zPosition = 1
        cam.addChild(upArrow)
        cam.addChild(downArrow)
        cam.addChild(leftArrow)
        cam.addChild(rightArrow)
        
//        playerMaxHealthLabel.text = ("Max Health \(player.maxHealth)")
//        playerMaxHealthLabel.fontColor = UIColor.black
//        playerMaxHealthLabel.fontSize = 50.0
//        playerMaxHealthLabel.fontName = "arial"
//        playerMaxHealthLabel.zPosition = 2.0
//        playerMaxHealthLabel.position = CGPoint(x: frame.midX - 200, y: frame.midY + 600)
//        cam.addChild(playerMaxHealthLabel)
        
        maxHealthNode.size = CGSize(width: CGFloat(Float(player.maxHealth)), height: 50)
        maxHealthNode.position = CGPoint(x: frame.minX + 50, y: frame.midY + 550)
        maxHealthNode.anchorPoint = CGPoint.zero
        maxHealthNode.zPosition = 1
        cam.addChild(maxHealthNode)

        healthNode.size = CGSize(width: CGFloat(Float(player.health)), height: 50)
        healthNode.position = CGPoint(x: frame.minX + 50, y: frame.midY + 550)
        healthNode.anchorPoint = CGPoint.zero
        healthNode.zPosition = 2
        cam.addChild(healthNode)

//        playerHealthLabel.text = ("Health \(player.health)")
//        playerHealthLabel.fontColor = UIColor.black
//        playerHealthLabel.fontSize = 50.0
//        playerHealthLabel.fontName = "arial"
//        playerHealthLabel.zPosition = 2.0
//        playerHealthLabel.position = CGPoint(x: frame.midX - 200, y: frame.midY + 550)
//        cam.addChild(playerHealthLabel)

//        playerLevelLabel.text = ("Level \(player.level)")
//        playerLevelLabel.fontColor = UIColor.black
//        playerLevelLabel.fontSize = 50.0
//        playerLevelLabel.fontName = "arial"
//        playerLevelLabel.zPosition = 2.0
//        playerLevelLabel.position = CGPoint(x: frame.midX - 200, y: frame.midY + 500)
//        cam.addChild(playerLevelLabel)

//        playerExpLabel.text = ("Exp \(player.exp)")
//        playerExpLabel.fontColor = UIColor.black
//        playerExpLabel.fontSize = 50.0
//        playerExpLabel.fontName = "arial"
//        playerExpLabel.zPosition = 2.0
//        playerExpLabel.position = CGPoint(x: frame.midX - 200, y: frame.midY + 450)
//        cam.addChild(playerExpLabel)

//        playerBonusLabel.text = ("Bonus +\(player.bonus)")
//        playerBonusLabel.fontColor = UIColor.black
//        playerBonusLabel.fontSize = 50.0
//        playerBonusLabel.fontName = "arial"
//        playerBonusLabel.zPosition = 2.0
//        playerBonusLabel.position = CGPoint(x: frame.midX - 225, y: frame.midY + 400)
//        cam.addChild(playerBonusLabel)
        
//        bossHealthLabel.text = (String(boss.health))
//        bossHealthLabel.fontColor = UIColor.black
//        bossHealthLabel.fontSize = 60.0
//        bossHealthLabel.fontName = "arial"
//        bossHealthLabel.zPosition = 2
//        bossHealthLabel.position = CGPoint(x: node2.size.width / 2 - 50, y: node2.size.height / 2)
//        node2.addChild(bossHealthLabel)
//        
//        enemyHealthLabel.text = (String(enemy.health))
//        enemyHealthLabel.fontColor = UIColor.black
//        enemyHealthLabel.fontSize = 60.0
//        enemyHealthLabel.fontName = "arial"
//        enemyHealthLabel.zPosition = 2
//        enemyHealthLabel.position = CGPoint(x: node3.size.width / 2 - 50, y: node3.size.height / 2)
//        node3.addChild(enemyHealthLabel)
    }
    
    func giveTileMapPhysicsBody(map: SKTileMapNode, name: String) {
        let tileMap = map
        let startingLocation:CGPoint = tileMap.position
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    let tileArray = tileDefinition.textures
                    
                    let tileTexture = tileArray[0]
                    
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    
                    let tileNode = SKSpriteNode(texture:tileTexture)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTexture, size: CGSize(width: (tileTexture.size().width), height: (tileTexture.size().height)))
                    tileNode.physicsBody?.linearDamping = 60.0
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.allowsRotation = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    
                    if name == "cliff" {
                        tileNode.name = "cliff"
                        tileNode.physicsBody?.categoryBitMask = CliffCategory
                        tileNode.physicsBody?.collisionBitMask = Node1Category
                    }
                    if name == "water" {
                        tileNode.name = "water"
                        tileNode.physicsBody?.categoryBitMask = WaterCategory
                        tileNode.physicsBody?.contactTestBitMask = Node1Category
                    }
                    
                    self.addChild(tileNode)
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startingLocation.x, y: tileNode.position.y + startingLocation.y)
                }
            }
        }
    }
    
    func collision(_ node: SKSpriteNode,_ monster: SKSpriteNode) {
        if monster.name == "water" {
            if player.health != 0 {
                player.health -= 1
                if player.health <= 0 {
                    node1.removeFromParent()
                }
            }
        }
        if monster.name == "node2" {
            if player.health != 0 && boss.health != 0 {
                boss.health -= player.doDamage()
                player.health -= boss.doDamage()
                if boss.health <= 0 {
                    monster.removeFromParent()
                    player.exp += boss.exp
                    player.levelUp()
                }
                if player.health <= 0 {
                    node1.removeFromParent()
                }
            }
        }
        if monster.name == "node3" {
            if player.health != 0 && enemy.health != 0 {
                enemy.health -= player.doDamage()
                player.health -= enemy.doDamage()
            }
            if enemy.health <= 0 {
                monster.removeFromParent()
                player.exp += enemy.exp
                player.levelUp()
            }
            if player.health <= 0 {
                node1.removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node!.name == "node1" {
            collision(contact.bodyA.node as! SKSpriteNode, contact.bodyB.node! as! SKSpriteNode)
        } else if contact.bodyB.node?.name == "node1" {
            collision(contact.bodyB.node! as! SKSpriteNode, contact.bodyA.node! as! SKSpriteNode)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if upArrow.contains(touch.location(in: cam)) {
            node1.run(SKAction.repeatForever(SKAction.moveBy(x: 0, y: 72, duration: movementSpeed)))
        }
        if downArrow.contains(touch.location(in: cam)) {
            node1.run(SKAction.repeatForever(SKAction.moveBy(x: 0, y: -72, duration: movementSpeed)))
        }
        if leftArrow.contains(touch.location(in: cam)) {
            node1.run(SKAction.repeatForever(SKAction.moveBy(x: -75, y: 0, duration: movementSpeed)))
        }
        if rightArrow.contains(touch.location(in: cam)) {
            node1.run(SKAction.repeatForever(SKAction.moveBy(x: 75, y: 0, duration: movementSpeed)))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if upArrow.contains(touch.location(in: cam)) {
            node1.removeAllActions()
        }
        if downArrow.contains(touch.location(in: cam)) {
            node1.removeAllActions()
        }
        if leftArrow.contains(touch.location(in: cam)) {
            node1.removeAllActions()
        }
        if rightArrow.contains(touch.location(in: cam)) {
            node1.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        maxHealthNode.size = CGSize(width: CGFloat(Float(player.maxHealth)), height: 50)
        healthNode.size = CGSize(width: CGFloat(Float(player.health)), height: 50)
        bossHealthLabel.text = (String(boss.health))
        enemyHealthLabel.text = (String(enemy.health))
    }
}
