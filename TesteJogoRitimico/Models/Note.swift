//
//  Note.swift
//  TesteJogoRitimico
//
//  Created by Marina Martin on 15/07/24.
//

import Foundation
import SpriteKit

class Note: NoteObject{
    var position: CGPoint
    var node: SKSpriteNode
    var type: colorType
    
    init(position: CGPoint, type: colorType, travelTime: Double) {
        self.position = position
        self.type = type
        
        self.node = SKSpriteNode(imageNamed: type == .blueType ? "DiscoBlue" : type == .pinkType ? "DiscoPink" : "blueAndPinkNote")
//        self.node.fillColor = type == .blueType ? .gameBlue :type == .pinkType ? .gamePink : .purple
        node.zPosition = 2
        node.position = position
        
        let action = SKAction.moveTo(x: -100, duration: travelTime)
        //let remove = SKAction.removeFromParent()
        //let sequence = SKAction.sequence([action,remove])
    
        node.run(action)
    }
    
    
    func update() {
        
    }
}
