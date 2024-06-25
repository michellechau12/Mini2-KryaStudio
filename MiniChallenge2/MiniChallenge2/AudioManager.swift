////
////  AudioManager.swift
////  MiniChallenge2
////
////  Created by Rio Ikhsan on 25/06/24.

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    var player: AVAudioPlayer?
    private var walkAudioPlayer: AVAudioPlayer?
    var isWalkSoundPlaying = false
    private var bombAudioPlayer: AVAudioPlayer?


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
    
    func playBombPlantedAlertMusic() {
        playMusic(named: "vo-bomb-planted-sfx", loop: false, volume: 1)
    }
    
    func playTerroristStartingMusic() {
        playMusic(named: "vo-gamestart-terrorist-sfx", loop: false, volume: 0.7)
    }
    
    func playFbiStartingMusic() {
        playMusic(named: "vo-gamestart-fbi-sfx", loop: false, volume: 0.7)
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
    
    func playWalkSound() {
            guard let url = Bundle.main.url(forResource: "walk-step-faster-sfx", withExtension: "mp3") else {
                print("Could not find walkSound.mp3")
                return
            }

            do {
                walkAudioPlayer = try AVAudioPlayer(contentsOf: url)
                            walkAudioPlayer?.prepareToPlay()
                            walkAudioPlayer?.numberOfLoops = -1
                            walkAudioPlayer?.play()
                            isWalkSoundPlaying = true
            } catch {
                print("Could not create audio player: \(error)")
            }
        }
    
    func stopWalkSound() {
        walkAudioPlayer?.stop()
        walkAudioPlayer?.currentTime = 0
        isWalkSoundPlaying = false
    }
    
    func playBombTimerSound() {
        guard let url = Bundle.main.url(forResource: "60sec-beep-bomb-sfx", withExtension: "mp3") else {
            print("Could not find bombTimerSound.mp3")
            return
        }
        do {
            bombAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bombAudioPlayer?.prepareToPlay()
            bombAudioPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func stopBombTimerSound() {
        bombAudioPlayer?.stop()
    }
    
    func playDefusingMusic() {
        guard let url = Bundle.main.url(forResource: "defusing-box-sfx", withExtension: "mp3") else {
            print("Could not find defusingMusic.mp3")
            return
        }
        do {
            bombAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bombAudioPlayer?.prepareToPlay()
            bombAudioPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func stopDefusingMusic() {
        bombAudioPlayer?.stop()
    }
    
    func playDelayingMusic() {
        guard let url = Bundle.main.url(forResource: "60sec-beep-bomb-sfx", withExtension: "mp3") else {
            print("Could not find bombTimerSound.mp3")
            return
        }
        do {
            bombAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bombAudioPlayer?.prepareToPlay()
            bombAudioPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func stopDelayingMusic() {
        bombAudioPlayer?.stop()
    }

    
    

    
    
    
    
    
}
