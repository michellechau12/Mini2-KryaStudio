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
    @Published var gameScene: GameScene!

    let serviceType = String.serviceName
    var session: MCSession
    var myConnectionId: MCPeerID

    @Published var availablePlayers: [MCPeerID] = []
    @Published var inviteReceived: Bool = false
    @Published var inviteReceivedFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false

    var shareVisibility: MCNearbyServiceAdvertiser
    var searchPlayers: MCNearbyServiceBrowser

    var isAvailableToPlay: Bool = false {
        didSet {
            if isAvailableToPlay {
                startAdvertising()
                startBrowsing()
            } else {
                stopAdvertising()
                stopBrowsing()
            }
        }
    }

    init(playerName: String){
        self.myConnectionId = MCPeerID(displayName: UIDevice.current.name)
        print("DEBUG: my ui device: \(self.myConnectionId)")
        self.session = MCSession(peer: myConnectionId, securityIdentity: nil, encryptionPreference: .required)
        self.shareVisibility = MCNearbyServiceAdvertiser(peer: myConnectionId, discoveryInfo: nil, serviceType: serviceType)
        self.searchPlayers = MCNearbyServiceBrowser(peer: myConnectionId, serviceType: serviceType)

        super.init()
        session.delegate = self
        shareVisibility.delegate = self
        searchPlayers.delegate = self
    }

    init(playerId: UUID) {
        self.myConnectionId = MCPeerID(displayName: String(playerId.uuidString.prefix(4)))
        self.session = MCSession(peer: myConnectionId, securityIdentity: nil, encryptionPreference: .required)
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
        print("DEBUG: Started advertising")
    }

    func stopAdvertising() {
        shareVisibility.stopAdvertisingPeer()
        print("DEBUG: Stopped advertising")
    }

    func startBrowsing() {
        searchPlayers.startBrowsingForPeers()
        print("DEBUG: Started browsing")
    }

    func stopBrowsing() {
        searchPlayers.stopBrowsingForPeers()
        availablePlayers.removeAll()
        print("DEBUG: Stopped browsing")
    }

    func setupGame(gameScene: GameScene) {
        self.gameScene = gameScene
        self.gameScene.mpManager = self
    }

    // sending data
    func send(player: MPPlayerModel) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            if let data = player.data() {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch {
            print("DEBUG Error: \(error.localizedDescription)")
        }
    }

    func send(map: MPMapModel) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            if let data = map.data() {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch {
            print("DEBUG Error: \(error.localizedDescription)")
        }
    }

    func send(bomb: MPBombModel) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            if let data = bomb.data() {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch {
            print("DEBUG Error: \(error.localizedDescription)")
        }
    }
    
    func updatePeerID(with displayName: String) {
            // Stop current session
            stopAdvertising()
            stopBrowsing()
            session.disconnect()
            
            // Reinitialize with new peer ID
            self.myConnectionId = MCPeerID(displayName: displayName)
            self.session = MCSession(peer: myConnectionId, securityIdentity: nil, encryptionPreference: .required)
            self.session.delegate = self
            self.shareVisibility = MCNearbyServiceAdvertiser(peer: myConnectionId, discoveryInfo: nil, serviceType: serviceType)
            self.shareVisibility.delegate = self
            self.searchPlayers = MCNearbyServiceBrowser(peer: myConnectionId, serviceType: serviceType)
            self.searchPlayers.delegate = self
            
            // Start new session
            startAdvertising()
            startBrowsing()
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
// Searching players
extension MultipeerConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            // adding advertising players to availablePlayers
            if !self.availablePlayers.contains(peerID) {
                self.availablePlayers.append(peerID)
                print("DEBUG: Found peer \(peerID.displayName)")
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = availablePlayers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.availablePlayers.remove(at: index)
            print("DEBUG: Lost peer \(peerID.displayName)")
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("DEBUG Error: Did not start browsing - \(error.localizedDescription)")
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
// Showing Visibility and Accepting Invites
extension MultipeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.inviteReceived = true
            self.inviteReceivedFrom = peerID
            self.invitationHandler = invitationHandler
            print("DEBUG: Received invitation from \(peerID.displayName)")
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("DEBUG Error: Did not start advertising - \(error.localizedDescription)")
    }
}

// MARK: - MCSessionDelegate
// session status: connected, connecting, or not
// session event: what happen in the game session that is shared between players
extension MultipeerConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                self.paired = false
                self.isAvailableToPlay = true
                print("DEBUG: Disconnected from \(peerID.displayName), ID: \(peerID)")
            case .connecting:
                print("DEBUG: Connecting to \(peerID.displayName), ID: \(peerID)")
            case .connected:
                self.paired = true
                self.isAvailableToPlay = false
                print("DEBUG: Connected to \(peerID.displayName), ID: \(peerID)")
            @unknown default:
                self.paired = false
                self.isAvailableToPlay = true
                print("DEBUG: Unknown state for \(peerID.displayName), ID: \(peerID)")
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if peerID == self.myConnectionId {
            // This is data that was sent by this device, so ignore it
            return
        }
        
        // receiving data
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

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}
