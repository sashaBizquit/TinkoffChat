//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol CommunicatorDelegate {
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    func didReceiveMessage(text: String, fromUserWithId: String, withMessageId: String)
}

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?)->())?)
    var delegate: CommunicatorDelegate? {get set}
}

class MultipeerCommunicator: NSObject, Communicator {
    
    var delegate: CommunicatorDelegate? {
        didSet {
            self.serviceAdvertiser.startAdvertisingPeer()
            self.serviceBrowser.startBrowsingForPeers()
        }
    }
    
    private var sessions = [MCPeerID:MCSession]()
    private var serviceAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceBrowser : MCNearbyServiceBrowser!
    private static let serviceType = "tinkoff-chat"
    static let userName = UIDevice.current.identifierForVendor?.description.offsetBy(8) ?? UIDevice.current.name
    static let myPeerId = MCPeerID(displayName: MultipeerCommunicator.userName)
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        let jsonObject: [String:String]  = [
            "eventType": "TextMessage",
            "text": string,
            "messageId": generateMessageId()
        ]
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            completionHandler?(false, NSError(domain: "Объект JSON не был создан", code: -2, userInfo: nil))
            return
        }
        do {
            guard let strongTuple = self.findSessionForUser(withId: userID) else {
                completionHandler?(false, NSError(domain: "Сессия для \(userID) не найдена", code: -1, userInfo: nil))
                return
            }
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            try strongTuple.1.send(data, toPeers: [strongTuple.0], with: .unreliable)
            completionHandler?(true, nil)
        }
        catch {
            completionHandler?(false, error)
        }
    }
    
    private func findSessionForUser(withId userID: String) -> (MCPeerID, MCSession)? {
        var tuple: (MCPeerID, MCSession)?
        for elem in sessions {
            if elem.key.displayName == userID {
                tuple = (elem.key, elem.value)
            }
        }
        return tuple
    }
    
    private func addSession(forId userId: MCPeerID) -> MCSession {
        for elem in sessions {
            if elem.key.displayName == userId.displayName {
                return elem.value
            }
        }
        
        let session = MCSession(peer: MultipeerCommunicator.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        sessions[userId] = session
        return session
    }
    
    override init() {
        super.init()
        self.setupAdvertiser()
        self.setupBrowser()
    }
    
    func generateMessageId() -> String {
        guard let id = "\(arc4random_uniform(UINT32_MAX)) + \(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)?.base64EncodedString()  else {
            assert(false, "data(using encoding:allowLossyConversion:) couldn't get data")
        }
        return id
    }
    
    private func setupBrowser() {
        self.serviceBrowser = MCNearbyServiceBrowser(peer: MultipeerCommunicator.myPeerId, serviceType: MultipeerCommunicator.serviceType)
        self.serviceBrowser.delegate = self
    }
    private func setupAdvertiser() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: MultipeerCommunicator.myPeerId,
                                                           discoveryInfo: ["userName": MultipeerCommunicator.userName],
                                                           serviceType: MultipeerCommunicator.serviceType)
        self.serviceAdvertiser.delegate = self
    }
}

extension MultipeerCommunicator : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if sessions.contains(where: {$0.key.displayName == peerID.displayName}) {print("advertiser - уже есть"); return}
        let session = addSession(forId: peerID)
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
}

extension MultipeerCommunicator : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if sessions.contains(where: {$0.key.displayName == peerID.displayName}) {print("browser - уже есть"); return}
        let session = addSession(forId: peerID)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        //delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"])
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = sessions.index(where: {$0.key.displayName == peerID.displayName}) {
            sessions.remove(at: index)
        }
        delegate?.didLostUser(userID: peerID.displayName)
    }
}

extension MultipeerCommunicator : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.didFoundUser(userID: peerID.displayName, userName: peerID.displayName)
            break
        default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: String]
            if let text = dict?["text"] {
                let messageId = dict?["messageId"] ?? ""
                delegate?.didReceiveMessage(text: text, fromUserWithId: peerID.displayName, withMessageId: messageId)
            }

        }
        catch {
            print("Error: \(error.localizedDescription)")
        }
        
        print("didReceiveData")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }

}

