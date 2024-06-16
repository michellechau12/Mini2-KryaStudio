//
//  MultipeerConnectionManager.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import MultipeerConnectivity
import SwiftUI

extension String {
    static var serviceName = "BombnChase"
}

class MultipeerConnectionManager: NSObject, ObservableObject {
    // published var of the inGameManager
    @Published var gameScene: GameScene!
    
    let serviceType = String.serviceName
    let session: MCSession
    let myConnectionId: MCPeerID
    
    @Published var availablePlayers: [MCPeerID] = []
    @Published var inviteReceived: Bool = false
    @Published var inviteReceivedFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    
    let shareVisibility: MCNearbyServiceAdvertiser
    let searchPlayers: MCNearbyServiceBrowser
    
    var isAvailableToPlay: Bool = false {
        didSet {
            if isAvailableToPlay {
                startAdvertising()
            }
            else {
                stopAdvertising()
            }
        }
    }
    
    init(playerId: UUID) {
        self.myConnectionId = MCPeerID(displayName: playerId.uuidString)
        self.session = MCSession(peer: myConnectionId)
        self.shareVisibility = MCNearbyServiceAdvertiser(peer: myConnectionId, discoveryInfo: nil, serviceType: serviceType)
        self.searchPlayers = MCNearbyServiceBrowser(peer: myConnectionId, serviceType: serviceType)
        
        super.init()
        session.delegate = self
        shareVisibility.delegate = self
        searchPlayers.delegate = self
    }
    
    deinit {
        stopAdvertising()
        stopBrowsing()
    }
    
    func startAdvertising() {
        shareVisibility.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        shareVisibility.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        searchPlayers.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        searchPlayers.stopBrowsingForPeers()
        availablePlayers.removeAll() // remove all data if stop browsing
    }
    
    func setupGame(gameScene: GameScene) {
        self.gameScene = gameScene
        self.gameScene.mpManager = self
    }
    
    func send(player: MPPlayerModel) {
        if session.connectedPeers.isEmpty == false {
            do {
                if let data = player.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }
    
    func send(map: MPMapModel) {
        if session.connectedPeers.isEmpty == false {
            do {
                if let data = map.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }
    
    func send(bomb: MPBombModel) {
        if session.connectedPeers.isEmpty == false {
            do {
                if let data = bomb.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }
}

// extension of the class to find others to play
extension MultipeerConnectionManager: MCNearbyServiceBrowserDelegate {
    // function that will be called if found someone sharing their visibility
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            // only add to list available peers if not in the list
            if self.availablePlayers.contains(peerID) == false {
                self.availablePlayers.append(peerID)
            }
        }
    }
    
    // function that will be called if someone stop sharing their visibility
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // check if someone is not in available peers, it will return
        guard let index = availablePlayers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.availablePlayers.remove(at: index)
        }
    }
}

extension MultipeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
    // this function will be called if the user received invitation
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.inviteReceived = true
            self.inviteReceivedFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MultipeerConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
    
    // this function will handle connection
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .notConnected:
                DispatchQueue.main.async {
                    self.paired = false
                    self.isAvailableToPlay = true
                }
            case .connected:
                DispatchQueue.main.async {
                    self.paired = true
                    self.isAvailableToPlay = false
                }
            default:
                DispatchQueue.main.async {
                    self.paired = false
                    self.isAvailableToPlay = true
                }
            }
    }
    
    // this function will handle receiving data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let player = try? JSONDecoder().decode(MPPlayerModel.self, from: data) {
            DispatchQueue.main.async {
                self.gameScene.handlePlayer(player: player, mpManager: self)
            }
        } else if let bomb = try? JSONDecoder().decode(MPBombModel.self, from: data) {
            DispatchQueue.main.async {
                self.gameScene.handleBomb(bomb: bomb, mpManager: self)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (Error?)?) { }
}


//import MultipeerConnectivity
//import SwiftUI
//
//extension String {
//    static var serviceName = "BombnChase"
//}
//
//class MultipeerConnectionManager: NSObject, ObservableObject {
//    // published var of the inGameManager
//    @Published var gameScene: GameScene!
//    
//    let serviceType = String.serviceName
//    let session: MCSession
//    let myConnectionId: MCPeerID
//    
//    
//    @Published var availablePlayers: [MCPeerID] = []
//    @Published var inviteReceived: Bool = false
//    @Published var inviteReceivedFrom: MCPeerID?
//    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
//    @Published var paired: Bool = false
//    
//    let shareVisibility: MCNearbyServiceAdvertiser
//    
//    let searchPlayers: MCNearbyServiceBrowser
//    
//    var isAvailableToPlay: Bool = false {
//        didSet {
//            if isAvailableToPlay {
//                startAdvertising()
//            }
//            else {
//                stopAdvertising()
//            }
//        }
//    }
//    
//    init(playerId: UUID) {
//        self.myConnectionId = MCPeerID(displayName: playerId.uuidString)
//        self.session = MCSession(peer: myConnectionId)
//        self.shareVisibility = MCNearbyServiceAdvertiser(peer: myConnectionId, discoveryInfo: nil, serviceType: serviceType)
//        self .searchPlayers = MCNearbyServiceBrowser(peer: myConnectionId, serviceType: serviceType)
//        
//        super.init()
//        session.delegate = self
//        shareVisibility.delegate = self
//        searchPlayers.delegate = self
//        
//    }
//    
//    deinit {
//        stopAdvertising()
//        stopBrowsing()
//    }
//    
//    func startAdvertising() {
//        shareVisibility.startAdvertisingPeer()
//    }
//    
//    func stopAdvertising() {
//        shareVisibility.stopAdvertisingPeer()
//    }
//    
//    func startBrowsing(){
//        searchPlayers.startBrowsingForPeers()
//    }
//    
//    func stopBrowsing(){
//        searchPlayers.stopBrowsingForPeers()
//        availablePlayers.removeAll() // remove all data if stop browsing
//    }
//    
//    func setupGame(gameScene: GameScene){
//        self.gameScene = gameScene
//        self.gameScene.mpManager = self
//    }
//    
//    func send(player: MPPlayerModel){
//        if session.connectedPeers.isEmpty == false {
//            do {
//                if let data = player.data() {
//                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//                }
//            }
//            catch {
//                print("DEBUG Error: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func send(map: MPMapModel){
//        if session.connectedPeers.isEmpty == false {
//            do {
//                if let data = map.data() {
//                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//                }
//            }
//            catch {
//                print("DEBUG Error: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func send(bomb: MPBombModel){
//        if session.connectedPeers.isEmpty == false {
//            do {
//                if let data = bomb.data() {
//                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//                }
//            }
//            catch {
//                print("DEBUG Error: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//}
//
//// extension of the class to find others to play
//extension MultipeerConnectionManager: MCNearbyServiceBrowserDelegate {
//    // function that will be called if found someone sharing their visibility
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        DispatchQueue.main.async {
//            // only add to list available peers if not in the list
//            if self.availablePlayers.contains(peerID) == false {
//                self.availablePlayers.append(peerID)
//            }
//        }
//    }
//    
//    // function that will be called if someone stop sharing their visibility
//    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        // check if someone is not in available peers, it will return
//        guard let index = availablePlayers.firstIndex(of: peerID) else { return }
//        DispatchQueue.main.async {
//            self.availablePlayers.remove(at: index)
//        }
//    }
//}
//
//extension MultipeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
//    // this function will be called if the user received invitation
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        DispatchQueue.main.async {
//            self.inviteReceived = true
//            self.inviteReceivedFrom = peerID
//            self.invitationHandler = invitationHandler
//        }
//    }
//}
//
//extension MultipeerConnectionManager: MCSessionDelegate {
//    // this function will handle connection
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        switch state {
//            case .notConnected:
//                DispatchQueue.main.async {
//                    self.paired = false
//                    self.isAvailableToPlay = true
//                }
//            case .connected:
//                DispatchQueue.main.async {
//                    self.paired = true
//                    self.isAvailableToPlay = false
//                }
//            default:
//                DispatchQueue.main.async {
//                    self.paired = false
//                    self.isAvailableToPlay = true
//                }
//            }
//    }
//    
//    // this function will handle receiving data
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        if let player = try? JSONDecoder().decode(MPPlayerModel.self, from: data) {
//            DispatchQueue.main.async {
//                self.gameScene.handlePlayer(player: player, mpManager: self)
//            }
//        }
//        else if let bomb = try? JSONDecoder().decode(MPBombModel.self, from: data){
//            DispatchQueue.main.async {
//                self.gameScene.handleBomb(bomb: bomb, mpManager: self)
//            }
//        }
//        
//        //add map event later
//    }
//    
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        
//    }
//    
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        
//    }
//    
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
//        
//    }
//    
//    
//}

    
