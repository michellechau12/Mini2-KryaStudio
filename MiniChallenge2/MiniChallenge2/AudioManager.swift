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
    var isMuted: Bool = false
    
    private var playerVolume: Float = 0.3
    private var walkAudioPlayerVolume: Float = 1.0
    private var bombAudioPlayerVolume: Float = 1.0
    
    
    private init() {}
    
    func playBackgroundMusic() {
        playerVolume = 0.3
        playMusic(named: "Hot-Wet-and-Happy-bgm", loop: true, volume: playerVolume)
    }
    
    func playGameMusic() {
        playerVolume = 0.3
        playMusic(named: "Famicom Battle-bgm", loop: true, volume: playerVolume)
    }
    
    func playFbiWinningMusic() {
        playerVolume = 0.5
        playMusic(named: "police-sirene-sfx", loop: false, volume: playerVolume)
    }
    
    func playTerroristWinningMusic() {
        playerVolume = 0.5
        playMusic(named: "explode-bomb-sfx", loop: false, volume: playerVolume)
    }
    
    func playBombPlantedAlertMusic() {
        playerVolume = 1
        playMusic(named: "vo-bomb-planted-sfx", loop: false, volume: playerVolume)
    }
    
    func playTerroristStartingMusic() {
        playerVolume = 0.7
        playMusic(named: "vo-gamestart-terrorist-sfx", loop: false, volume: playerVolume)
    }
    
    func playFbiStartingMusic() {
        playerVolume = 0.7
        playMusic(named: "vo-gamestart-fbi-sfx", loop: false, volume: playerVolume)
    }
    
    private func playMusic(named name: String, loop: Bool, volume: Float) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = loop ? -1 : 0
                player?.volume = isMuted ? 0 : volume  // Adjust volume based on mute state
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
            walkAudioPlayerVolume = 1.0
            walkAudioPlayer = try AVAudioPlayer(contentsOf: url)
            walkAudioPlayer?.prepareToPlay()
            walkAudioPlayer?.numberOfLoops = -1
            walkAudioPlayer?.volume = isMuted ? 0 : walkAudioPlayerVolume  // Adjust volume based on mute state
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
            bombAudioPlayerVolume = 1.0
            bombAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bombAudioPlayer?.prepareToPlay()
            bombAudioPlayer?.volume = isMuted ? 0 : bombAudioPlayerVolume  // Adjust volume based on mute state
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
            bombAudioPlayerVolume = 1.0
            bombAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bombAudioPlayer?.prepareToPlay()
            bombAudioPlayer?.volume = isMuted ? 0 : bombAudioPlayerVolume  // Adjust volume based on mute state
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
            bombAudioPlayerVolume = 1.0
            bombAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bombAudioPlayer?.prepareToPlay()
            bombAudioPlayer?.volume = isMuted ? 0 : bombAudioPlayerVolume  // Adjust volume based on mute state
            bombAudioPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    
    func stopDelayingMusic() {
        bombAudioPlayer?.stop()
    }
    
    // Function to mute or unmute all audio
    func toggleMute() {
        isMuted.toggle()
        player?.volume = isMuted ? 0 : playerVolume  // Adjust volume based on mute state and stored volume
        walkAudioPlayer?.volume = isMuted ? 0 : walkAudioPlayerVolume
        bombAudioPlayer?.volume = isMuted ? 0 : bombAudioPlayerVolume
    }
}


