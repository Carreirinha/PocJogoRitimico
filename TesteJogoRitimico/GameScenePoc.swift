//
//  GameScenePoc.swift
//  TesteJogoRitimico
//
//  Created by Rafael Carreira on 28/06/24.
//

import Foundation
import SpriteKit
import AVFoundation

class GameScenePoc: SKScene, SKPhysicsContactDelegate {
    
    var gameData: GameData?
    
    var background: SKSpriteNode = SKSpriteNode(imageNamed: "Background")
    var paperNormal: SKSpriteNode = SKSpriteNode(imageNamed: "PaperNormal")
    var paperSigned: SKSpriteNode = SKSpriteNode(imageNamed: "PaperSigned")
    var stampDown: SKSpriteNode = SKSpriteNode(imageNamed: "StampDown")
    var stampUp: SKSpriteNode = SKSpriteNode(imageNamed: "StampUp")
    var scoreLabel: SKLabelNode = SKLabelNode(text: "Score: ")
    var touched:Bool = false
    let actionHide: SKAction = SKAction.hide()
    let actionShow: SKAction = SKAction.unhide()
    let actionWait: SKAction = SKAction.wait(forDuration: 0.2)
    let remove: SKAction = SKAction.removeFromParent()
    
    var bpm: Float = 120
    var sec_per_beat: Float = 0
    var timerIntervalPerBeat: TimeInterval = 0
    var musicDuration = 0
    var beats_in_music: Int = 0
    var beat_playing: Int = 1
    
    var player: AVAudioPlayer?
    var play: Bool = false
    var renderPaper = true
    var objectCount = 0
    var scorePoints = 0
    var cur_time: Float = 0
    var gameState = GameState.menu
    
    var node: SKShapeNode = SKShapeNode()
    let PlayBttn: SKNode = SKNode()
    var isTouching: Bool = false
    
    
    enum GameState {
        case menu
        case inGame
    }
    
    override func didMove(to view: SKView) {
        setMenu()
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 1 || contact.bodyB.categoryBitMask == 1 {
            isTouching = true
            print("tocou")
        }else{
            isTouching = false
            print("n tocou")
        }
    }
    
    func startGame(){
        removeAllChildren()
        gameState = .inGame
        setBackground()
        setHands()
        playSound("Metronomo","wav")
        player?.pause()
        player?.prepareToPlay()
        createPaper()
        setScore()
        sec_per_beat = 60/bpm
        beats_in_music = Int(Float(player!.duration) * sec_per_beat)
        //aqui eu sei quantos beats vao ter na musica
        node = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
        node.position.x = UIScreen.main.bounds.width / 2
        node.position.y = UIScreen.main.bounds.height / 2
        node.fillColor = .clear
        node.strokeColor = .red
        node.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width: 100, height: 100))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.contactTestBitMask = 1
        node.physicsBody?.categoryBitMask = 2
        node.zPosition = 0
        addChild(node)
    }
    
    func setMenu(){
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
        gameData?.MenuObjects.append(PlayBttn)
    }
    
    func resetGame(){
        gameState = GameState.menu
        removeAllChildren()
        setMenu()
        play = false
        renderPaper = true
        objectCount = 0
        scorePoints = 0
        scoreLabel = SKLabelNode(text: "Score: 0")
        gameData?.objects.removeAll()
        
    }
    
    func createPaper(){
        objectCount = Int(player!.duration)/2
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == .inGame{
            if !play{
                play = true
                player?.play()
            }

            
            
            cur_time = Float(player!.currentTime + 0.5)
            
            if floor(cur_time.truncatingRemainder(dividingBy: 2)) == 0 && renderPaper && objectCount != 0{
                objectCount -= 1
                gameData?.create(factory: PaperFactory())
                renderLast()
                renderPaper = false
                
            }else if floor(cur_time.truncatingRemainder(dividingBy: 2)) == 1{
                renderPaper = true
            }
            
            if  !player!.isPlaying{
                gameState = .menu
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
                    resetGame()
                    
                })
                
            }
            
            if let objects = gameData?.objects {
                
                for  object in objects {
                    if let paper = object as? Paper {
                        paper.update()
                    }
                }
            }
        }
    }
    
    
    func renderLast(){
        if let objects = gameData?.objects {
            objects.last!.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
            objects.last!.node.physicsBody?.isDynamic = false
            objects.last!.node.physicsBody?.categoryBitMask = 1
            objects.last!.node.physicsBody?.usesPreciseCollisionDetection = true
            addChild(objects.last!.node)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .menu{
            let touch = touches.first?.location(in: self)
            
            if let objects = gameData?.MenuObjects {
                for (index, object) in objects.enumerated() {
                    
                    if let button = object as? SKNode {
                        
                        if button.contains(touch!) {
                            if button.name == "play"{
                                startGame()
                            }
                        }
                    }
                }
            }
        }
        if gameState == .inGame{
            
            let sequenceShow = SKAction.sequence([actionHide, actionWait, actionShow])
            //mostrar depois esconder a mão
            let sequenceHide = SKAction.sequence([actionShow, actionWait, actionHide])
            
            stampUp.run(sequenceShow)
            stampDown.run(sequenceHide)
            
            if let objects2 = gameData?.objects {
                
                if let paper = objects2.last as? Paper{
                    
                    if isTouching{
                        
                        paper.touched = true
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.prepare()
                        let animation: SKAction = SKAction.customAction(withDuration: 0, actionBlock: { [self] _,_ in
                            gameData?.objects.removeFirst()
                        })
                        let sequence = SKAction.sequence([actionWait, animation])
                        paper.node.run(sequence)
                        generator.impactOccurred()
                        scorePoints += 10
                        scoreLabel.text = "Score: \(scorePoints)"
                    }
                }
            }
        }
    }
    
    func setBackground() {
        background.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        background.position = CGPoint(x: Int(background.size.width)/2, y: Int(background.size.height)/2)
        addChild(background)
        
        background.zPosition = -999
        
    }
    
    func setHands(){
        stampUp.position = CGPoint(x: background.position.x + 150, y: background.position.y)
        stampUp.zPosition = 1
        
        addChild(stampUp)
        
        stampDown.position = stampUp.position
        stampDown.position.y = stampUp.position.y - 100
        stampDown.zPosition = stampUp.zPosition
        stampDown.isHidden = true
        addChild(stampDown)
        
    }
//    
//    func setTime(){
//        sec_per_beat = Float(bpm/60)
//        timerIntervalPerBeat = TimeInterval(1/sec_per_beat)
//    }
    
    func setScore(){
        scoreLabel.position = CGPoint(x: 730, y: 25)
        scoreLabel.zPosition = 10
        scoreLabel.isUserInteractionEnabled = false
        scoreLabel.fontColor = .black
        scoreLabel.fontSize = 24
        addChild(scoreLabel)
    }
    
    
    func playSound(_ nome: String, _ ext: String) {
        guard let url = Bundle.main.url(forResource: nome, withExtension: ext) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
