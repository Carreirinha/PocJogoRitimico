//
//  NoteObject.swift
//  TesteJogoRitimico
//
//  Created by Marina Martin on 15/07/24.
//

import Foundation
import SpriteKit

protocol NoteObject{
    var position: CGPoint { get set }
    var node: SKSpriteNode { get set }
    var type: colorType { get set }

    func update()
    
}

enum colorType {
    case blueType
    case pinkType
    case blueAndPinkType
}
