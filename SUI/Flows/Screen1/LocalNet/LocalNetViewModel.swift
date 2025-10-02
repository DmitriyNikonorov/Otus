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
    /// Уникальный ID для поиска устройств рядом
    private var peerID: MCPeerID
    /// Сессия по поиску устройств
    private var session: MCSession
    /// Сервис отвечающий за распространение данных о данном устройстве
    private var advertiser: MCNearbyServiceAdvertiser? // Используем этот вместо MCAdvertiserAssistant
    /// Сервис для поиска других устройств
    private var browser: MCNearbyServiceBrowser?

    @Published var connectedPeers: [MCPeerID] = []
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    @Published var availablePeers: [MCPeerID] = []
    @Published var isAdvertising = false
    @Published var isBrowsing = false
    @Published var invitationDeviceName: String?
    @Published var isShowAlert: Bool = false

    var outerInvitationHandler: ((Bool, MCSession?) -> Void)?
    var getSession: MCSession {
        return session
    }

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

    /// Начать транслировать устройство в сеть
    func startAdvertising() {
        // Тормазим предыдущую сессию
        stopAdvertising()

        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: ["app": "mpc-demo"],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

        isAdvertising = true
        print("📡 С устройства \(peerID) начата трансляция сервиса: \(serviceType)")
    }

    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        isAdvertising = false
    }

    func startBrowsing() {
        stopBrowsing() // Останавливаем предыдущий поиск

        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()

        isBrowsing = true
        print("🔍 Начат поиск сервиса: \(serviceType)")
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
        guard
            !text.isEmpty,
            !connectedPeers.isEmpty
        else {
            return
        }

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
            case .connected:
                stateName = "подключено"

            case .connecting:
                stateName = "подключается"

            case .notConnected:
                stateName = "не подключено"

            @unknown default:
                stateName = "неизвестно"
            }

            print("🔗 Состояние \(peerID.displayName): \(stateName)")
            print("Всего подключенных: \(self.connectedPeers.count)")
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
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("📩 Получено приглашение от: \(peerID.displayName)")
        invitationDeviceName = peerID.displayName
        isShowAlert = true
        // Автоматически принимаем приглашение

        outerInvitationHandler = invitationHandler
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("❌ Ошибка трансляции: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("🔍 Найдено устройство: \(peerID.displayName)")
        if !availablePeers.contains(where: { $0.displayName == peerID.displayName }) {
            DispatchQueue.main.async {
                self.availablePeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("👻 Потеряно устройство: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0.displayName == peerID.displayName }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("❌ Ошибка поиска: \(error)")
    }
}

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
