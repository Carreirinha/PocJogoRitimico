//
//  GameData.swift
//  TesteJogoRitimico
//
//  Created by Rafael Carreira on 02/07/24.
//

import Foundation
import SpriteKit
import UIKit

@Observable class GameData{
    let back: SKSpriteNode = SKSpriteNode(imageNamed: "Background")
    let paper: SKSpriteNode = SKSpriteNode(imageNamed: "PaperNormal")
    
    var objects: [GameObject] = []
    var MenuObjects: [SKNode] = []
    var score: Int = 0
    func createPaper(){
         create(factory: PaperFactory())
    }
   
    func create(factory: GOFactory){
        let object: GameObject = factory.createGameObject(position: CGPoint(x: 0, y: UIScreen.main.bounds.height/2) )
        objects.append(object)
        
    }
}
