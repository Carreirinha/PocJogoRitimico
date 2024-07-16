//
//  ContentView.swift
//  TesteJogoRitimico
//
//  Created by Rafael Carreira on 26/06/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: GameScenePoc{
        let scene = GameScenePoc()
        scene.gameData = GameData()
        scene.scaleMode = .resizeFill
        return scene
    }
    var sceneTeste: GameScene{
        let scene = GameScene()
//        scene.gameData = GameData()
        scene.scaleMode = .resizeFill
        return scene
    }
    var body: some View {
        VStack {
            SpriteView(scene: scene, debugOptions: [.showsNodeCount,.showsFPS])
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
