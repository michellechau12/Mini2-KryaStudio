////
////  AudioManager.swift
////  MiniChallenge2
////
////  Created by Rio Ikhsan on 25/06/24.
////
//
//import AVFoundation
//
//class AudioManager {
//    static let shared = AudioManager()
//    var player: AVAudioPlayer?
//
//    private init() {}
//
//    func playBackgroundMusic() {
//        playMusic(named: "Hot-Wet-and-Happy-bgm")
//    }
//
//    func playGameMusic() {
//        playMusic(named: "Famicom Battle-bgm")
//    }
//
//    private func playMusic(named name: String) {
//        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
//            do {
//                player = try AVAudioPlayer(contentsOf: url)
//                player?.numberOfLoops = -1 // Loop indefinitely
//                player?.volume = 0.5 // Set volume to 0.5
//                player?.play()
//            } catch {
//                print("Error playing \(name): \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func stopMusic() {
//        player?.stop()
//    }
//}


import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    var player: AVAudioPlayer?

    private init() {}

    func playBackgroundMusic() {
        playMusic(named: "Hot-Wet-and-Happy-bgm", loop: true, volume: 0.3)
    }

    func playGameMusic() {
        playMusic(named: "Famicom Battle-bgm", loop: true, volume: 0.3)
    }

    func playFbiWinningMusic() {
        playMusic(named: "police-sirene-sfx", loop: false, volume: 0.5)
    }

    func playTerroristWinningMusic() {
        playMusic(named: "explode-bomb-sfx", loop: false, volume: 0.5)
    }

    private func playMusic(named name: String, loop: Bool, volume: Float) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = loop ? -1 : 0
                player?.volume = volume
                player?.play()
            } catch {
                print("Error playing \(name): \(error.localizedDescription)")
            }
        }
    }

    func stopMusic() {
        player?.stop()
    }
}
