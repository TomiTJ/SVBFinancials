//
//  ErrorView.swift
//  SVB-App
//
//  Created by Savya Rai on 10/5/2025.
//

// Reusable error display with retry button
import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .multilineTextAlignment(.center)
            Button("Retry", action: retryAction)
        }
        .padding()
    }
}
