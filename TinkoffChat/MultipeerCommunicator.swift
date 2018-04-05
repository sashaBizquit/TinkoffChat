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
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?)->())?)
    var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}

class MultipeerCommunicator: NSObject, Communicator {
    
    var delegate: CommunicatorDelegate? {
        didSet {
            self.serviceAdvertiser.startAdvertisingPeer()
            self.serviceBrowser.startBrowsingForPeers()
        }
    }
    
    private var sessions = [MCPeerID:MCSession]()
    var online: Bool
    private var serviceAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceBrowser : MCNearbyServiceBrowser!
    private let serviceType = "tinkoff-chat"
    static let myPeerId = MCPeerID(displayName: "Lykov Aleksandr")
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        let jsonObject: [String:String]  = [
            "eventType": "TextMessage",
            "text": string,
            "messageId": generateMessageId()
        ]

        if JSONSerialization.isValidJSONObject(jsonObject) {
            do {
                var tuple: (MCPeerID, MCSession)?
                for elem in sessions {
                    if elem.key.displayName == userID {
                        tuple = (elem.key, elem.value)
                    }
                }
                if let strongTuple = tuple {
                    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                    try strongTuple.1.send(data, toPeers: [strongTuple.0], with: .reliable)
                    completionHandler?(true, nil)
                }
                else {completionHandler?(false, NSError(domain: "Сессия для \(userID) не найдена", code: -1, userInfo: nil)) }
            }
            catch {
                completionHandler?(false, error)
            }
        }
        else {
            completionHandler?(false, NSError(domain: "Объект JSON не был создан", code: -2, userInfo: nil))
        }
    }
    
    private func addSession(forId userId: MCPeerID) -> MCSession {
        for elem in sessions {
            if elem.key.displayName == userId.displayName {
                return elem.value
            }
        }
        let session = MCSession(peer: MultipeerCommunicator.myPeerId)
        session.delegate = self
        sessions[userId] = session
        return session
    }
    
    override init() {
        online = true
        super.init()
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: MultipeerCommunicator.myPeerId,
                                                           discoveryInfo: ["userName": "Lykov Aleksandr"],
                                                           serviceType: serviceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: MultipeerCommunicator.myPeerId, serviceType: serviceType)
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX)) + \(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
    }
}

extension MultipeerCommunicator : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let session = addSession(forId: peerID)
        invitationHandler(online, session)
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
        let session = addSession(forId: peerID)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"])
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
    }
}

extension MultipeerCommunicator : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.didFoundUser(userID: peerID.displayName, userName: nil)
            break
        case .notConnected:
            delegate?.didLostUser(userID: peerID.displayName)
            break
        default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: String]
            if let text = dict?["text"] {
                delegate?.didReceiveMessage(text: text, fromUser: peerID.displayName, toUser: "")
            }
            else {
                print("мне прислали кал")
            }
        }
        catch {
            print("ошибочка: \(error.localizedDescription)")
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

