//
//  LoadingView.swift
//  SVB-App
//
//  Created by Savya Rai on 10/5/2025.
//

// Reusable spinner for loading states
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
