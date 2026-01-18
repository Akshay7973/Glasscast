//
//  GlassButton.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI

import SwiftUI
import SwiftUI

struct GlassButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            #endif
            action()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .disabled(isLoading)
    }
}

