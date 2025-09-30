//
//  LocalNetViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 30.09.2025.
//

import MultipeerConnectivity
import SwiftUI

class MPCManager: NSObject, ObservableObject {
    private let serviceType = "mpc-chat"

    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser? // Используем этот вместо MCAdvertiserAssistant
    private var browser: MCNearbyServiceBrowser?

    @Published var connectedPeers: [MCPeerID] = []
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    @Published var availablePeers: [MCPeerID] = []
    @Published var isAdvertising = false
    @Published var isBrowsing = false

    override init() {
        // Создаем уникальный ID с временной меткой для отладки
        let deviceName = UIDevice.current.name
        let timestamp = Int(Date().timeIntervalSince1970)
        peerID = MCPeerID(displayName: "\(deviceName)-\(timestamp)")

        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)

        super.init()
        session.delegate = self

        print("🚀 MPCManager инициализирован: \(peerID.displayName)")
    }

    func startAdvertising() {
        stopAdvertising() // Останавливаем предыдущую рекламу

        advertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                              discoveryInfo: ["app": "mpc-demo"],
                                              serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

        isAdvertising = true
        print("📡 Начата реклама службы: \(serviceType)")
    }

    func startBrowsing() {
        stopBrowsing() // Останавливаем предыдущий поиск

        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()

        isBrowsing = true
        print("🔍 Начат поиск службы: \(serviceType)")
    }

    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        isAdvertising = false
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        availablePeers.removeAll()
        isBrowsing = false
    }

    func connectToPeer(_ peer: MCPeerID) {
        browser?.invitePeer(peer, to: session, withContext: nil, timeout: 30)
        print("📨 Отправлено приглашение к: \(peer.displayName)")
    }

    func sendMessage(_ text: String) {
        guard !text.isEmpty, !connectedPeers.isEmpty else { return }

        do {
            if let data = text.data(using: .utf8) {
                try session.send(data, toPeers: connectedPeers, with: .reliable)

                let message = ChatMessage(text: text, isLocal: true)
                DispatchQueue.main.async {
                    self.messages.append(message)
                }
                print("📤 Сообщение отправлено: \(text)")
            }
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
    }

    func disconnect() {
        session.disconnect()
        stopAdvertising()
        stopBrowsing()
        connectedPeers.removeAll()
        availablePeers.removeAll()
        isConnected = false
    }

    deinit {
        disconnect()
    }
}

// MARK: - MCSessionDelegate
extension MPCManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            self.isConnected = !session.connectedPeers.isEmpty

            let stateName: String
            switch state {
            case .connected: stateName = "connected"
            case .connecting: stateName = "connecting"
            case .notConnected: stateName = "notConnected"
            @unknown default: stateName = "unknown"
            }

            print("🔗 Состояние \(peerID.displayName): \(stateName)")
            print("   Всего подключенных: \(self.connectedPeers.count)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let text = String(data: data, encoding: .utf8) {
            let message = ChatMessage(text: text, isLocal: false, sender: peerID.displayName)
            DispatchQueue.main.async {
                self.messages.append(message)
            }
            print("📥 Сообщение получено от \(peerID.displayName): \(text)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📩 Получено приглашение от: \(peerID.displayName)")
        // Автоматически принимаем приглашение
        invitationHandler(true, self.session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("❌ Ошибка рекламы: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("🔍 Найден пир: \(peerID.displayName)")
        if !availablePeers.contains(where: { $0.displayName == peerID.displayName }) {
            DispatchQueue.main.async {
                self.availablePeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("👻 Потерян пир: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0.displayName == peerID.displayName }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("❌ Ошибка поиска: \(error)")
    }
}
//class MPCManager: NSObject, ObservableObject {
//    private let serviceType = "mpc-chat"
//
//    private var peerID: MCPeerID
//    private var session: MCSession
//    private var advertiser: MCAdvertiserAssistant?
//    private var browser: MCBrowserViewController?
//
//    @Published var connectedPeers: [MCPeerID] = []
//    @Published var messages: [ChatMessage] = []
//    @Published var isConnected = false
//    @Published var showBrowser = false
//
//    override init() {
//        // Создаем уникальный ID для устройства
//        peerID = MCPeerID(displayName: UIDevice.current.name)
//        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
//
//        super.init()
//        session.delegate = self
//    }
//
//    // MARK: - Public Methods
//
//    func startAdvertising() {
//        advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
//        advertiser?.start()
//    }
//
//    func stopAdvertising() {
//        advertiser?.stop()
//        advertiser = nil
//    }
//
//    func showBrowserView() {
//        showBrowser = true
//    }
//
//    func getBrowserViewController() -> UIViewController {
//        let browser = MCBrowserViewController(serviceType: serviceType, session: session)
//        browser.delegate = self
//        self.browser = browser
//        return browser
//    }
//
//    func sendMessage(_ text: String) {
//        guard !text.isEmpty, !connectedPeers.isEmpty else { return }
//
//        do {
//            if let data = text.data(using: .utf8) {
//                try session.send(data, toPeers: connectedPeers, with: .reliable)
//
//                // Добавляем свое сообщение в историю
//                let message = ChatMessage(text: text, isLocal: true)
//                DispatchQueue.main.async {
//                    self.messages.append(message)
//                }
//            }
//        } catch {
//            print("Ошибка отправки: \(error)")
//        }
//    }
//
//    func disconnect() {
//        session.disconnect()
//        stopAdvertising()
//    }
//}
//
//// MARK: - MCSessionDelegate
//extension MPCManager: MCSessionDelegate {
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        DispatchQueue.main.async {
//            self.connectedPeers = session.connectedPeers
//            self.isConnected = !session.connectedPeers.isEmpty
//
//            print("Состояние изменилось: \(peerID.displayName) - \(state.rawValue)")
//        }
//    }
//
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        if let text = String(data: data, encoding: .utf8) {
//            let message = ChatMessage(text: text, isLocal: false, sender: peerID.displayName)
//            DispatchQueue.main.async {
//                self.messages.append(message)
//            }
//        }
//    }
//
//    // Неиспользуемые обязательные методы
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
//}
//
//// MARK: - MCBrowserViewControllerDelegate
//extension MPCManager: MCBrowserViewControllerDelegate {
//    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
//        browserViewController.dismiss(animated: true)
//        showBrowser = false
//    }
//
//    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
//        browserViewController.dismiss(animated: true)
//        showBrowser = false
//    }
//}
//
// MARK: - Data Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isLocal: Bool
    let sender: String
    let timestamp = Date()

    init(text: String, isLocal: Bool, sender: String = UIDevice.current.name) {
        self.text = text
        self.isLocal = isLocal
        self.sender = sender
    }
}
