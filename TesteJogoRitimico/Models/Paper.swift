//
//  Paper.swift
//  TesteJogoRitimico
//
//  Created by Rafael Carreira on 02/07/24.
//

import Foundation
import SpriteKit

class Paper: GameObject{
    var position: CGPoint
    var node: SKSpriteNode
    var touched: Bool = false
    
    init(position: CGPoint) {
        self.position = position
        
        self.node = SKSpriteNode(imageNamed: "PaperNormal")
        node.setScale(0.5)
        node.zPosition = 0
        node.position = position
        let action = SKAction.moveTo(x: 860, duration: 1)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action,remove])
        
        node.run(sequence)
    }
    
    
    func update() {
        
        
        if touched{
            node.texture = SKTexture(imageNamed: "PaperSigned")
        }
        
        
    }
    
    
}
