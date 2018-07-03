//
//  PubSubService.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/29/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import CocoaMQTT

class PubSubService {
    let host: String = "getcanoe.io"
    let port: UInt16 = 1885
    let mqtt: CocoaMQTT
    let clientID: String
    var onIncomingBlock: ((IncomingBlock) -> Void)?
    var onConnect: (() -> Void)?
    
    init?(clientID: String?, username: String?, pw: String?) {
        guard let clientID = clientID, let username = username, let pw = pw else { return nil }
        self.clientID = clientID
        Lincoln.log("Connecting to: \(host):\(port) for client: \(clientID)")

        self.mqtt = CocoaMQTT(clientID: clientID, host: self.host, port: self.port)
        self.mqtt.username = username
        self.mqtt.password = pw
        self.mqtt.enableSSL = true
        self.mqtt.keepAlive = 60
        self.mqtt.cleanSession = true
        self.mqtt.autoReconnect = true
        self.mqtt.autoReconnectTimeInterval = 60
        self.mqtt.delegate = self
        self.mqtt.dispatchQueue = DispatchQueue.global(qos: .userInteractive)
        self.mqtt.connect()
    }
    
    func subscribe(to accounts: [String]) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "??"
        let payload: [String: Any] = ["name": "nanoblocks", "accounts": accounts, "version": version, "wallet": clientID]
        guard mqtt.connState == .connected,
            let jsonStr = String.json(payload) else { return }
        mqtt.publish("wallet/\(clientID)/register", withString: jsonStr)
        mqtt.subscribe("wallet/\(clientID)/block/#", qos: .qos0)
    }
}

extension PubSubService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            DispatchQueue.main.async {
                self.onConnect?()
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {

    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let msg = message.string else { return }
        Lincoln.log("Published message: \(msg)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {

    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let msg = message.string else { return }
        Lincoln.log("Received message for '\(message.topic)': \(msg)")
        switch message.topic {
        case "wallet/\(clientID)/block/state":
            guard let data = msg.data(using: .utf8) else { return }
            guard let incomingBlock = try? JSONDecoder().decode(IncomingBlock.self, from: data) else { return }
            DispatchQueue.main.async {
                self.onIncomingBlock?(incomingBlock)
            }
        default:
            break
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        Lincoln.log("Subscribed to topic: \(topic)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {

    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {

    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {

    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        Lincoln.log(err?.localizedDescription ?? "")
    }
}

