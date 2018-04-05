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
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error)->())?)
    var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}

class MultipeerCommunicator: NSObject, Communicator {
    
    var delegate: CommunicatorDelegate?
    var online: Bool
    private var serviceAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceBrowser : MCNearbyServiceBrowser!
    private let serviceType = "tinkoff-chat"
    private let myPeerId = MCPeerID(displayName: "Lykov Aleksandr")
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error) -> ())?) {
    }
    
    override init() {
        online = true
        super.init()
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId,
                                                           discoveryInfo: ["userName": "Lykov Aleksandr"],
                                                           serviceType: serviceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX)) + \(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
    }
}

extension MultipeerCommunicator : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        //invitationHandler(true, self.session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
}

extension MultipeerCommunicator : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let peerName = info?["userName"] {
            let session = MCSession(peer: self.myPeerId)
            session.delegate = self
            print("foundPeer: \(peerName)")
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
        print("foundPeer: \(peerID)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
}

extension MultipeerCommunicator : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        if peerID == peerId {
//            if state != .connected { return}
//            if flag {return}
//            flag = true
//            let jsonObject: [String:String]  = [
//                "eventType": "TextMessage",
//                "text": "ЛЫКОВ",
//                "messageId": gen()
//            ]
//
//            if JSONSerialization.isValidJSONObject(jsonObject) {
//                do {
//
//                    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
//                    print("yes json")
//                    try session.send(data, toPeers: [peerID], with: .unreliable)
//                    print("yes send")
//                }
//                catch {
//                    print(error)
//                }
//            }
//        }
        print("\(peerID) didChangeState")
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        if peerID == peerId {
//            //let jsonString = String(data: data, encoding: .utf8)
//            do {
//
//                let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: String]
//                print("готов парсить")
//                if let text = dict?["text"] {
//                    print("тЕКСТ")
//                    print("ПОЛУЧИЛ: \(text)")
//                }
//            }
//            catch {
//                print("ошибочка")
//                print(error)
//            }
//
//        }
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

