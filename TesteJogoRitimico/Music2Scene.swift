//
//  Music2Scene.swift
//  TesteJogoRitimico
//
//  Created by Marina Martin on 15/07/24.
//

import Foundation
import SpriteKit
import AVFoundation
import UIKit

class Music2Scene: SKScene{
    var gameData: GameData?
    
    var backgroundNotes: SKSpriteNode = SKSpriteNode(imageNamed: "rectangleBackground")
    var pinkButton: SKSpriteNode = SKSpriteNode(imageNamed: "pinkButton")
    var blueButton: SKSpriteNode = SKSpriteNode(imageNamed: "blueButton")
    var goodArea: SKShapeNode = SKShapeNode()
    var finalArea: SKShapeNode = SKShapeNode()
    var feedbackLabel: SKLabelNode = SKLabelNode(text: "")
    
    var player: AVAudioPlayer?
    var play: Bool = false
    var startMusic: Bool = false
    
    var isRendering = false
    
    var musicStartDelay: Double = 1.5
    
    var gameSecond: Double = 0
    var renderTime: TimeInterval = 0
    var changeTime: TimeInterval = 0.25
    
    var currentMeasure: Float =  0.5
    var beatCounter: Float = 0.5
    var bpm: Float = 120.0
    var secondsPerBeat: Float = 0
    
    var spawnBeat_1: Bool = false
    var spawnBeat_1_5: Bool = false
    var spawnBeat_2: Bool = false
    var spawnBeat_2_5: Bool = false
    var spawnBeat_3: Bool = false
    var spawnBeat_3_5: Bool = false
    var spawnBeat_4: Bool = false
    var spawnBeat_4_5: Bool = false
    
    var finalBeat: Int = 40
    var conductorTime: [Int] = [0,5,9,13,17,21,25,29,33]
    var conductorTimeIndex: Int = 0
    var conductorBeats: [Bool] = [true,true,true,true,true,false,true,true
                                  ,true,false,true,true,false,false,false,false
                                  ,true,true,true,true,true,false,true,true
                                  ,true,false,true,true,false,false,false,false
                                  ,true,true,true,true,true,true,false,false
                                  ,false,false,true,true,true,true,false,false
                                  ,true,true,true,true,false,false,true,true
                                  ,true,true,true,true,false,false,true,true
                                  ,false,false,false,false,false,false,false]
    var conductorBeatsIndex: Int = 0
    func playSound(_ nome: String, _ ext: String) {
        guard let url = Bundle.main.url(forResource: nome, withExtension: ext) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Start
    
    override func didMove(to view: SKView) {
        startGame()
    }
    
    func startGame(){
        setBackground()
        setButtons()
        setGoodArea()
        setFinalArea()
        setLabel()
        
        secondsPerBeat = 60 / bpm
        
        player?.prepareToPlay()
        player?.pause()
    }
    
    // MARK: Set Elements
    
    func setBackground() {
        backgroundColor = .white
        
        backgroundNotes.size = CGSize(width: UIScreen.main.bounds.width, height: 90)
        backgroundNotes.position = CGPoint(x: Int(backgroundNotes.size.width)/2, y: Int(backgroundNotes.size.height)/2)
        addChild(backgroundNotes)
        
        backgroundNotes.zPosition = -10
    }
    
    func setButtons(){
        pinkButton.position = CGPoint(x: 50, y: 50)
        addChild(pinkButton)
        pinkButton.zPosition = 1
        
        blueButton.position = CGPoint(x: UIScreen.main.bounds.width - 50, y: 50)
        addChild(blueButton)
        blueButton.zPosition = 1
    }
    
    func setGoodArea(){
        let rectangle = SKShapeNode(rectOf: CGSize(width: 90, height: 90))
        rectangle.fillColor = .gray
        rectangle.position = CGPoint(x: UIScreen.main.bounds.width/2, y: 45)
        goodArea = rectangle
        addChild(goodArea)
        goodArea.zPosition = 1
    }
    
    func setFinalArea(){
        let rectangle = SKShapeNode(rectOf: CGSize(width: 1, height: 90))
        rectangle.fillColor = .clear
        rectangle.strokeColor = .clear
        rectangle.position = CGPoint(x: UIScreen.main.bounds.width/2, y: 45)
        finalArea = rectangle
        addChild(finalArea)
        finalArea.zPosition = 1
    }
    
    func setLabel(){
        feedbackLabel.position = CGPoint(x: 350, y: 100)
        feedbackLabel.zPosition = 10
        feedbackLabel.isUserInteractionEnabled = false
        feedbackLabel.fontColor = .black
        feedbackLabel.fontSize = 30
        addChild(feedbackLabel)
    }
    
    // MARK: Update
    
    override func update(_ currentTime: TimeInterval) {
        calculateTime(currentTime: currentTime)
        
        if gameSecond >= musicStartDelay && !startMusic{
            startMusic = true
            self.playSound("twoLane", "wav")
        }
        
        if !play && gameSecond >= (musicStartDelay - Double(secondsPerBeat * 2)){
            play = true
            
            noteGenerator()
        }
        
        checkFinalAreaCollision()
        
        if gameData?.gameState == .menu{
            gameData!.menu.gameData = gameData
            gameData!.menu.scaleMode = .aspectFill
            self.view?.presentScene(gameData!.menu)
        }
    }
    
    // MARK: Touch began
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first?.location(in: self)
        
        if pinkButton.frame.contains(touch!) {
            locationNote(type: .pinkType)
        }
        if blueButton.frame.contains(touch!) {
            locationNote(type: .blueType)
        }
    }
    
    // MARK: Note generator
    
    func noteGenerator(){
        if !isRendering{
            conductorNotes()
        }
    }
    
    func conductorNotes(){
        var initialTimer: Timer?
        
        initialTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(secondsPerBeat / 2), repeats: true) { [self] timer in
            beatCounter += 0.5
            currentMeasure += 0.5
            if self.currentMeasure >= 5 {
                self.currentMeasure = 1
            }
            
            if beatCounter >= 40 {
                resetGame()
            }
            
            if conductorTime.count > (conductorTimeIndex + 1){
                if Int(beatCounter) >= conductorTime[conductorTimeIndex + 1]{
                    conductorTimeIndex += 1
                    conductorBeatsIndex += 8
                }
            }
            
//            if beatCounter > 0{
//                spawnBeat_1 = true
//                spawnBeat_1_5 = true
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = true
//                spawnBeat_3_5 = false
//                spawnBeat_4 = true
//                spawnBeat_4_5 = true
//            }
//            if beatCounter >= 5 {
//                spawnBeat_1 = true
//                spawnBeat_1_5 = false
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = false
//                spawnBeat_3_5 = false
//                spawnBeat_4 = false
//                spawnBeat_4_5 = false
//                
//            }
//            if beatCounter >= 9 {
//                spawnBeat_1 = true
//                spawnBeat_1_5 = true
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = true
//                spawnBeat_3_5 = false
//                spawnBeat_4 = true
//                spawnBeat_4_5 = true
//                
//            }
//            if beatCounter >= 13 {
//                spawnBeat_1 = true
//                spawnBeat_1_5 = false
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = false
//                spawnBeat_3_5 = false
//                spawnBeat_4 = false
//                spawnBeat_4_5 = false
//                
//            }
//            if beatCounter >= 17 {
//                spawnBeat_1 = true
//                spawnBeat_1_5 = true
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = true
//                spawnBeat_3_5 = true
//                spawnBeat_4 = false
//                spawnBeat_4_5 = false
//                
//            }
//            if beatCounter >= 21 {
//                spawnBeat_1 = false
//                spawnBeat_1_5 = false
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = true
//                spawnBeat_3_5 = true
//                spawnBeat_4 = false
//                spawnBeat_4_5 = false
//            }
//            if beatCounter >= 25 {
//                spawnBeat_1 = true
//                spawnBeat_1_5 = true
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = false
//                spawnBeat_3_5 = false
//                spawnBeat_4 = true
//                spawnBeat_4_5 = true
//                
//            }
//            if beatCounter >= 29 {
//                spawnBeat_1 = true
//                spawnBeat_1_5 = true
//                spawnBeat_2 = true
//                spawnBeat_2_5 = true
//                spawnBeat_3 = false
//                spawnBeat_3_5 = false
//                spawnBeat_4 = true
//                spawnBeat_4_5 = true
//                
//            }
//            //Nao produz nota a partir daqui mesmo com a musica ainda tocando
//            if beatCounter >= 33 {
//                spawnBeat_1 = false
//                spawnBeat_1_5 = false
//                spawnBeat_2 = false
//                spawnBeat_2_5 = false
//                spawnBeat_3 = false
//                spawnBeat_3_5 = false
//                spawnBeat_4 = false
//                spawnBeat_4_5 = false
//                
//            }
//            if beatCounter >= 40 {
//                resetGame()
//            }
            switch currentMeasure{
            case 1:
                if conductorBeats[conductorBeatsIndex]{
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 1")
                    renderNote(type:.blueType)
                }
            case 1.5:
                if conductorBeats[conductorBeatsIndex + 1]{
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 1.5")
                    renderNote(type:.blueType)
                }
            case 2:
                if conductorBeats[conductorBeatsIndex + 2]{
                    renderNote(type:.blueType)
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 2")
                }
            case 2.5:
                if conductorBeats[conductorBeatsIndex + 3]{
                    renderNote(type:.blueType)
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 2.5")
                }
            case 3:
                if conductorBeats[conductorBeatsIndex + 4]{
                    renderNote(type:.blueType)
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 3")
                }
            case 3.5:
                if conductorBeats[conductorBeatsIndex + 5]{
                    renderNote(type:.blueType)
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 3.5")
                }
            case 4:
                if conductorBeats[conductorBeatsIndex + 6]{
                    renderNote(type:.blueType)
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 4")
                }
            case 4.5:
                if conductorBeats[conductorBeatsIndex + 7]{
                    renderNote(type:.blueType)
                    //          print("beatCounter: \(beatCounter)")
                    //          print("spawn 4.5")
                }
            default:
                break
            }
            
        }
        
        isRendering = true
    }
    
    // MARK: Funcs
    
    func calculateTime(currentTime: TimeInterval){
        if currentTime > renderTime{
            if renderTime > 0{
                gameSecond += 0.25
            }
            renderTime = currentTime + changeTime
        }
    }
    
    func renderNote(type: colorType){
        gameData?.createNFactory(factory: NoteFactory(), type: type)
        if let notes = (type == .pinkType ? gameData?.pinkNotes : gameData?.blueNotes){
            addChild(notes.last!.node)
        }
    }
    
    func destroyNote(type: colorType){
        if type == .pinkType{
            if gameData?.pinkNotes != nil{
                gameData?.pinkNotes.first?.node.removeFromParent()
                gameData?.pinkNotes.removeFirst()
            }
        }else{
            if gameData?.blueNotes != nil{
                gameData?.blueNotes.first?.node.removeFromParent()
                gameData?.blueNotes.removeFirst()
            }
        }
        
    }
    
    func labelAnimation(){
        let action0 = SKAction.fadeIn(withDuration: 0)
        let action = SKAction.moveTo(y: 120, duration: 0.5)
        let action2 = SKAction.fadeOut(withDuration: 0.1)
        let action3 = SKAction.moveTo(y: 100, duration: 0)
        let sequence = SKAction.sequence([action0,action, action2, action3])
        feedbackLabel.run(sequence)
    }
    
    func locationNote(type: colorType){
        if let notes = (type == .pinkType ? gameData?.pinkNotes : gameData?.blueNotes) {
            if let note = notes.first as? Note{
                if goodArea.frame.contains(note.node.position){
                    destroyNote(type: type)
                    feedbackLabel.text = "Good!"
                    
                }
                else{
                    destroyNote(type: type)
                    feedbackLabel.text = "missed..."
                }
                labelAnimation()
            }
        }
    }
    
    func checkFinalAreaCollision(){
        if let notes = gameData?.pinkNotes{
            if let note = notes.first as? Note{
                if finalArea.frame.contains(note.node.position){
                    destroyNote(type: note.type)
                    feedbackLabel.text = "missed..."
                    labelAnimation()
                }
            }
        }
        if let notes = gameData?.blueNotes{
            if let note = notes.first as? Note{
                if finalArea.frame.contains(note.node.position){
                    destroyNote(type: note.type)
                    feedbackLabel.text = "missed..."
                    labelAnimation()
                }
            }
        }
    }
    
    func resetGame(){
        //MARK: Ending
        secondsPerBeat = 0
        beatCounter = 0.5
        currentMeasure = 0.5
        startMusic = false
        renderTime = 0
        changeTime = 0.25
        gameSecond = 0
        spawnBeat_1 = false
        spawnBeat_1_5 = false
        spawnBeat_2 = false
        spawnBeat_2_5 = false
        spawnBeat_3 = false
        spawnBeat_3_5 = false
        spawnBeat_4 = false
        spawnBeat_4_5 = false
        gameData?.objects.removeAll()
        gameData?.gameState = .menu
      }
}
