//
//  AudioManager.swift
//  MiniChallenge2
//
//  Created by Ferris Leroy Winata on 20/06/24.
//


import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playBombTimerSound() {
        guard let url = Bundle.main.url(forResource: "bombTimerSound", withExtension: "mp3") else {
            print("Could not find bombTimerSound.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func stopBombTimerSound() {
        audioPlayer?.stop()
    }
}
