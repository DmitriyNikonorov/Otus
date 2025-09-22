//
//  HeaderView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 21.09.2025.
//

import SwiftUI

// MARK: - Компоненты интерфейса

struct HeaderView: View {
    let isFaceDetected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Face AR Scanner")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    Circle()
                        .fill(isFaceDetected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)

                    Text(isFaceDetected ? "Лицо обнаружено" : "Лицо не найдено")
                        .font(.subheadline)
                }
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct NoFaceDetectedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "face.dashed")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("Наведите камеру на лицо")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Распознавание работает только на устройствах с TrueDepth камерой")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
