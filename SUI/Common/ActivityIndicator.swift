//
//  ActivityIndicator.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 08.06.2025.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.hidesWhenStopped = true
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating
        ? uiView.startAnimating()
        : uiView.stopAnimating()
    }
}
