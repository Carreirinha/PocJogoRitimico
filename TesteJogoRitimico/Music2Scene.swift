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
    var DJDesk: SKSpriteNode = SKSpriteNode(imageNamed: "DJDesk")
    var vitrola = SKSpriteNode(imageNamed: "Vitrola")
    var agulha = SKSpriteNode(imageNamed: "Agulha")
    var DiscoCover = SKSpriteNode(imageNamed: "DiscoCover")
    var DiscoBack = SKSpriteNode(imageNamed: "DiscoBack")
    var perfectArea: SKShapeNode = SKShapeNode()
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
    
    var pinkButtonClicked: Bool = false
    var blueButtonClicked: Bool = false
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
                                  ,false,false,false,false,false,false,false,false]
    var conductorBeatsIndex: Int = 0
    
    var initialTimer: Timer?
    
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
        view?.isMultipleTouchEnabled = true
        
        setBackground()
        setButtons()
        setPerfectArea()
        setGoodArea()
        setFinalArea()
        secondsPerBeat = 60 / bpm
        
        player?.prepareToPlay()
        
    }
    
    // MARK: Set Elements
    
    func setBackground() {
        backgroundColor = .darkBlue
        
        setVitrola()
        setDiscoBack()
        setDiscoCover()
        setDJDesk()
    }
    
    func setDJDesk(){
        DJDesk.position = CGPoint(x: UIScreen.main.bounds.width/2, y: 50)
        DJDesk.setScale(1.01)
        addChild(DJDesk)
        
        DJDesk.zPosition = -10
    }
    
    func setVitrola(){
        vitrola.position = CGPoint(x: 130, y: 300)
        vitrola.zPosition = -1
        addChild(vitrola)
        agulha.position = CGPoint(x: 130, y: 300)
        agulha.zPosition = 2
        addChild(agulha)
    }
    
    func setDiscoBack(){
        DiscoBack.position = CGPoint(x: 435, y: 300)
        DiscoBack.zPosition = -2
        addChild(DiscoBack)
    }
    func setDiscoCover(){
        DiscoCover.position = CGPoint(x: 770, y: 300)
        DiscoCover.zPosition = 3
        addChild(DiscoCover)
    }
    
    func setButtons(){
        pinkButton.position = CGPoint(x: UIScreen.main.bounds.width - 54, y: 53)
        pinkButton.setScale(2)
        pinkButton.alpha = 0
        addChild(pinkButton)
        pinkButton.zPosition = 1
        
        blueButton.position = CGPoint(x: 47, y: 53)
        blueButton.setScale(2)
        blueButton.alpha = 0
        addChild(blueButton)
        blueButton.zPosition = 1
    }
    
    func setPerfectArea(){
        let rectangle = SKShapeNode(rectOf: CGSize(width: 47, height: 74))
        rectangle.fillColor = .green
        rectangle.alpha = 0
        rectangle.position = CGPoint(x: 130, y: 300)
        perfectArea = rectangle
        addChild(perfectArea)
        perfectArea.zPosition = 1
    }
   
    
    func setGoodArea(){
        let rectangle = SKShapeNode(rectOf: CGSize(width: 37, height: 74))
        rectangle.fillColor = .yellow
        rectangle.alpha = 0
        rectangle.position = CGPoint(x: 185.5, y: 300)
        goodArea = rectangle
        addChild(goodArea)
        goodArea.zPosition = 0.9
    }
    
    func setFinalArea(){
        let rectangle = SKShapeNode(rectOf: CGSize(width: 22, height: 74))
        rectangle.fillColor = .red
        rectangle.alpha = 0
        rectangle.position = CGPoint(x: 82, y: 300)
        finalArea = rectangle
        addChild(finalArea)
        finalArea.zPosition = 100

    }
    
    // MARK: Update
    
    override func update(_ currentTime: TimeInterval) {
        calculateTime(currentTime: currentTime)
        
        checkFinalAreaCollision()
        
        if gameSecond >= musicStartDelay && !startMusic{
            startMusic = true
            self.playSound("twoLane", "wav")
        }
        
        //Aqui eu to antecipando o spawn das notas
        if !play && gameSecond >= (musicStartDelay - Double(secondsPerBeat * 3)){
        
            play = true
            
            noteGenerator()
        }
        
        if gameData?.gameState == .menu{
            gameData!.menu.gameData = gameData
            gameData!.menu.scaleMode = .aspectFill
            self.view?.presentScene(gameData!.menu)
        }
    }
    
    // MARK: Touch began
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            
            if blueButton.frame.contains(touch.location(in: self)){
                blueButtonClicked = true
            }
            if pinkButton.frame.contains(touch.location(in: self)){
                pinkButtonClicked = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pinkButtonClicked && blueButtonClicked {
//            print("dois")
            locationNote(type: .blueAndPinkType)
        }
        else if pinkButtonClicked && !blueButtonClicked{
//            print("rosa")
            locationNote(type: .pinkType)
            
        }
        else if blueButtonClicked && !pinkButtonClicked{
//            print("azul")
            locationNote(type: .blueType)
        }
        
        blueButtonClicked = false
        pinkButtonClicked = false
        
    }

    // MARK: Note generator
    
    func noteGenerator(){
        if !isRendering{
            conductorNotes()
        }
    }
    
    func conductorNotes(){
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
    
            switch currentMeasure{
            case 1:
                if conductorBeats[conductorBeatsIndex]{
                    renderNote(type:.blueType)
                }
            case 1.5:
              
                if conductorBeats[conductorBeatsIndex + 1]{
                    renderNote(type:.blueType)
                }
            case 2:
                if conductorBeats[conductorBeatsIndex + 2]{
                    renderNote(type:.blueType)
                }
            case 2.5:
                if conductorBeats[conductorBeatsIndex + 3]{
                    renderNote(type:.blueType)

                }
            case 3:
                if conductorBeats[conductorBeatsIndex + 4]{
                    renderNote(type:.pinkType)
                }
            case 3.5:

                if conductorBeats[conductorBeatsIndex + 5]{
                    renderNote(type:.pinkType)
                }
            case 4:
                if conductorBeats[conductorBeatsIndex + 6]{
                    renderNote(type:.pinkType)
                }
            case 4.5:
                if conductorBeats[conductorBeatsIndex + 7]{
                    renderNote(type:.blueAndPinkType)
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
        if let notes = (type == .pinkType ? gameData?.pinkNotes : type == .blueType ? gameData?.blueNotes : gameData?.blueAndPinkNotes){
            addChild(notes.last!.node)
        }
    }
    
    func destroyNote(type: colorType){
        if type == .pinkType{
            if gameData?.pinkNotes != nil{
//                print("deletou")
                gameData?.pinkNotes.first?.node.removeFromParent()
                gameData?.pinkNotes.removeFirst()
            }
            
        }else if type == .blueType{
            if gameData?.blueNotes != nil{
//                print("deletou")
                gameData?.blueNotes.first?.node.removeFromParent()
                gameData?.blueNotes.removeFirst()
            }
        }
        else{
            if gameData?.blueAndPinkNotes != nil {
                gameData?.blueAndPinkNotes.first?.node.removeFromParent()
                gameData?.blueAndPinkNotes.removeFirst()
            }
        }
        
    }
    
    func labelAnimation(_ text: String){
        
        let feedbackLabelClone: SKLabelNode = SKLabelNode(fontNamed: "SF Pro Bold")
        feedbackLabelClone.text = text
        feedbackLabelClone.color =  text == "Great!" ? .green : text == "Good!" ? .yellow : .black
        
        feedbackLabelClone.position = CGPoint(x: 350, y: 100)
        feedbackLabelClone.zPosition = 10
        feedbackLabelClone.isUserInteractionEnabled = false
        feedbackLabelClone.fontColor = .white
        feedbackLabelClone.fontSize = 25
        
        let action0 = SKAction.fadeIn(withDuration: 0)
        let action = SKAction.moveTo(y: 150, duration: 0.2)
        let action2 = SKAction.fadeOut(withDuration: 0.1)
        let action4 = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action0,action, action2,action4])
        addChild(feedbackLabelClone)
        feedbackLabelClone.run(sequence)
        
    }
    
    func locationNote(type: colorType){
        var text = ""
        if let notes = (type == .pinkType ? gameData?.pinkNotes : type == .blueType ? gameData?.blueNotes : gameData?.blueAndPinkNotes) {
            if let note = notes.first as? Note{
                
                if perfectArea.frame.contains(note.node.position) && !goodArea.frame.contains(note.node.position){
                    destroyNote(type: type)
                    text = "Perfect!"
                }
                else if goodArea.frame.contains(note.node.position){
                    destroyNote(type: type)
                    text = "Good!"
                }
                else if !perfectArea.frame.contains(note.node.position) && !goodArea.frame.contains(note.node.position){
                    text = "missed..."
                }
                labelAnimation(text)
            }
        }
    }
    
    func checkFinalAreaCollision(){
        var text = ""
        if let notes = gameData?.pinkNotes{
            if let note = notes.first as? Note{
                if finalArea.frame.contains(note.node.position){
                    destroyNote(type: note.type)
                    text = "missed..."
                    labelAnimation(text)
                }
                
            }
        }
        
        if let notes = gameData?.blueNotes{
            if let note = notes.first as? Note{
                if finalArea.frame.contains(note.node.position){
                    destroyNote(type: note.type)
                    text = "missed..."
                    labelAnimation(text)
                }
                
            }
        }
        
        if let notes = gameData?.blueAndPinkNotes{
            if let note = notes.first as? Note{
                if finalArea.frame.contains(note.node.position){
                    destroyNote(type: note.type)
                    text = "missed..."
                    labelAnimation(text)
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
        gameData?.objects.removeAll()
        gameData?.gameState = .menu
        
        initialTimer?.invalidate()
        initialTimer = nil
      }
}
