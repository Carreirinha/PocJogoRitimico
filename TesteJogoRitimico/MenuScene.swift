//
//  MenuScene.swift
//  TesteJogoRitimico
//
//  Created by Marina Martin on 11/07/24.
//

import Foundation
import SpriteKit

class MenuScene: SKScene{
    let PlayBttn: SKNode = SKNode()
    let LaneBttn: SKNode = SKNode()
    
    var gameData: GameData?
    
    let game = MusicScene(size: UIScreen.main.bounds.size)
    let twoLaneScene = Music2Scene(size: UIScreen.main.bounds.size)
    
    override func didMove(to view: SKView) {
        removeAllChildren()
        
        setMenu()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameData?.gameState == .inGame{
            
            //testar se reseta o menu ou não
            //removeAllChildren()
            game.gameData = gameData
            game.scaleMode = .aspectFill
            self.view?.presentScene(game)
            
        }else if gameData?.gameState == .twoLane{
            twoLaneScene.gameData = gameData
            twoLaneScene.scaleMode = .aspectFill
            self.view?.presentScene(twoLaneScene)
        }
    }
    
    func setMenu(){
        // Botão do Play
        let playNode: SKLabelNode = SKLabelNode(text: "Play")
        playNode.fontSize = 40
        playNode.fontColor = .black
        playNode.zPosition = 0
        let backNode: SKShapeNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: (-playNode.frame.width/2 - 10), y: -playNode.frame.height/2), size: CGSize(width: 80, height: 60)))
        backNode.fillColor = .white
        backNode.strokeColor = .black
        backNode.lineWidth = 3
        backNode.zPosition = -1
        
        PlayBttn.addChild(backNode)
        PlayBttn.addChild(playNode)
        PlayBttn.name = "play"
        PlayBttn.position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        addChild(PlayBttn)
        
        // Botão das DuasLanes
        let laneNode: SKLabelNode = SKLabelNode(text: "Duas Lanes")
        laneNode.fontSize = 40
        laneNode.fontColor = .black
        laneNode.zPosition = 0
        let bgNode: SKShapeNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: (-laneNode.frame.width/2 - 10), y: -laneNode.frame.height/2), size: CGSize(width: 210, height: 60)))
        bgNode.fillColor = .white
        bgNode.strokeColor = .black
        bgNode.lineWidth = 3
        bgNode.zPosition = -1
        
        LaneBttn.addChild(laneNode)
        LaneBttn.addChild(bgNode)
        LaneBttn.name = "lane"
        LaneBttn.position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY - 70)
        addChild(LaneBttn)
        
        
        gameData?.MenuObjects.append(PlayBttn)
        gameData?.MenuObjects.append(LaneBttn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first?.location(in: self)
        
        if let objects = gameData?.MenuObjects {
            for object in objects {
                
                if let button = object as SKNode? {
                    
                    if button.contains(touch!) {
                        if button.name == "play" {
                            //startGame()
                            gameData?.gameState = .inGame
                        } else if button.name == "lane" {
                            gameData?.gameState = .twoLane
                        }
                    }
                }
            }
        }
    }
}
