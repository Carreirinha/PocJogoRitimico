//
//  Scene.swift
//  TesteJogoRitimico
//
//  Created by Rafael Carreira on 26/06/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.blue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sceneTwo = SceneTwo(size: UIScreen.main.bounds.size)
        sceneTwo.scaleMode = .aspectFill
        self.view?.presentScene(sceneTwo, transition: SKTransition.fade(withDuration: 0.1))
    }
}
