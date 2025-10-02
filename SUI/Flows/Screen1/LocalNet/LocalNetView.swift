//
//  LocalNetView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 30.09.2025.
//

import MultipeerConnectivity
import SwiftUI

struct ContentView: View {
    @State private var showAlert = false

    var body: some View {
        VStack {
            Button("Показать алерт") {
                showAlert = true
            }
            .padding()
        }
        .alert("Внимание!", isPresented: $showAlert) {
            Button("Отмена", role: .cancel) {
                print("Нажата отмена")
            }

            Button("OK", role: .none) {
                print("Нажата OK")
            }
        } message: {
            Text("Вы уверены, что хотите продолжить?")
        }
    }
}

struct MPCView: View {
    @StateObject private var mpcManager = MPCManager()
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            headerView
            peerListView
            chatView
            inputView
        }
        .onAppear {
            // Запускаем и рекламу и поиск одновременно
            mpcManager.startAdvertising()
            mpcManager.startBrowsing()
        }
        .onDisappear {
            mpcManager.disconnect()
        }
        .alert("Внимание!", isPresented: $mpcManager.isShowAlert) {
            Button("Отмена", role: .cancel) {
                if mpcManager.outerInvitationHandler != nil {
                    mpcManager.outerInvitationHandler!(false, mpcManager.getSession)
                }
                mpcManager.isShowAlert = false
            }

            Button("Принять", role: .none) {
                if mpcManager.outerInvitationHandler != nil {
                    mpcManager.outerInvitationHandler!(true, mpcManager.getSession)
                }
            }
        } message: {
            Text("Получено приглашение от \(mpcManager.invitationDeviceName ?? "")")
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Multipeer Chat")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Мое устройство: \(UIDevice.current.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        StatusIndicator(isActive: mpcManager.isAdvertising, text: "Видимость")
                        StatusIndicator(isActive: mpcManager.isBrowsing, text: "Поиск")
                        StatusIndicator(isActive: mpcManager.isConnected, text: "Подключено")
                    }
                }

                Spacer()

                Button("Перезапуск") {
                    mpcManager.disconnect()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        mpcManager.startAdvertising()
                        mpcManager.startBrowsing()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private var peerListView: some View {
        VStack(alignment: .leading) {
            if !mpcManager.availablePeers.isEmpty {
                Text("Доступные устройства:")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(mpcManager.availablePeers, id: \.displayName) { peer in
                            Button(peer.displayName) {
                                mpcManager.connectToPeer(peer)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var chatView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(mpcManager.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            .onChange(of: mpcManager.messages.count) { _, _ in
                if let last = mpcManager.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
        .background(Color(.systemBackground))
    }

    private var inputView: some View {
        HStack(spacing: 12) {
            TextField("Введите сообщение...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(!mpcManager.isConnected)

            Button("Отправить") {
                mpcManager.sendMessage(messageText)
                messageText = ""
            }
            .buttonStyle(.borderedProminent)
            .disabled(messageText.isEmpty || !mpcManager.isConnected)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct StatusIndicator: View {
    let isActive: Bool
    let text: String

    var body: some View {
        HStack {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption2)
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isLocal {
                Spacer()
            }

            VStack(alignment: message.isLocal ? .trailing : .leading, spacing: 4) {
                Text(message.sender)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isLocal ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isLocal ? .white : .primary)
                    .cornerRadius(12)
            }

            if !message.isLocal {
                Spacer()
            }
        }
    }
}
