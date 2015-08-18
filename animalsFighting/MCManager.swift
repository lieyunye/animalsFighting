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
    
    func connectedDevicesChanged(manager : MCManager, connectedDevices: [String])
    func didRecivedData(manager : MCManager, message: Message)
    
}

class MCManager: NSObject,MCNearbyServiceBrowserDelegate,MCNearbyServiceAdvertiserDelegate {
    
    private let mcServiceType = "lieyunye-af"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var delegate : MCManagerDelegate?
    
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
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session?.delegate = self
        return session
        }()
    
    func sendData(message:Message) {
        var data = NSKeyedArchiver.archivedDataWithRootObject(message)
        if session.connectedPeers.count > 0 {
            var error : NSError?
            if !self.session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error) {
                NSLog("%@", "\(error)")
            }
        }
    }
    
}

extension MCManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println("didNotStartAdvertisingPeer:\(error.description)")
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("didReceiveInvitationFromPeer:\(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MCManager : MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println("didNotStartBrowsingForPeers:\(error.description)")
    }
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("foundPeer:\(peerID)")
        println("invitePerr:\(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("lostPeer;\(peerID)")
    }
}

extension MCSessionState {
    func stringValue() -> String {
        switch (self) {
        case .NotConnected:return "NotConnected"
        case .Connecting:return "Connecting"
        case .Connected:return "Connected"
        default:return "Unkown"
        }
    }
}

extension MCManager : MCSessionDelegate {
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
//        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        NSLog("%@", "didReceiveData: \(data)")
//        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        var message : Message = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Message

        self.delegate?.didRecivedData(self, message: message)
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}