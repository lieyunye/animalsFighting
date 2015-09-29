//
//  MCManager.swift
//  animalsFighting
//
//  Created by lieyunye on 8/18/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MCManagerDelegate {
    
    func connectedStateChanged(connectedState:String)
    func didRecivedData(manager : MCManager, message: Message)
    
}

class MCManager: NSObject {
    
    private let mcServiceType = "lieyunye-af"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var delegate : MCManagerDelegate?
    
    var connectState:ConnectState = ConnectState.ConnectStateUnkown
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: mcServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: mcServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    class var sharedInstance : MCManager {
        struct Static {
            static let instance : MCManager = MCManager()
        }
        return Static.instance
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
        }()
    
    func sendData(message:Message) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(message)
        NSLog("sendData+++++++++++++++++++++\(data)")
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
        }
    }
    
}

extension MCManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertisingPeer:\(error.description)")
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        print("didReceiveInvitationFromPeer:\(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MCManager : MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers:\(error.description)")
    }
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer:\(peerID)")
        print("invitePerr:\(peerID)")
        print("withDiscoveryInfo:\(info)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer;\(peerID)")
    }
}

extension MCSessionState {
    func stringValue() -> String {
        switch (self) {
        case .NotConnected:return ConnectState.ConnectStateNotConnected.rawValue
        case .Connecting:return ConnectState.ConnectStateConnecting.rawValue
        case .Connected:return ConnectState.ConnectStateConnected.rawValue
        default:return ConnectState.ConnectStateUnkown.rawValue
        }
    }
}

extension MCManager : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID.displayName) didChangeState: \(state.stringValue())")
            switch state.stringValue() {
            case ConnectState.ConnectStateConnecting.rawValue:
                connectState = ConnectState.ConnectStateConnecting
                break
            case ConnectState.ConnectStateConnected.rawValue:
                connectState = ConnectState.ConnectStateConnected
                break
            case ConnectState.ConnectStateNotConnected.rawValue:
                connectState = ConnectState.ConnectStateNotConnected
                break
            default:
                connectState = ConnectState.ConnectStateUnkown
            }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate?.connectedStateChanged(state.stringValue())
        })
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let message : Message = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Message
        self.delegate?.didRecivedData(self, message: message)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: ((Bool) -> Void)) {
        certificateHandler(true)
    }
}