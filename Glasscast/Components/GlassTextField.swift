//
//  GlassTextField.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

// MARK: - Components/GlassTextField.swift
import SwiftUI

struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool  // Added for focus states
    
    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder)
                    .foregroundColor(.white.opacity(0.4)))  // Styled prompt
            } else {
                TextField("", text: $text, prompt: Text(placeholder)
                    .foregroundColor(.white.opacity(0.4)))  // Styled prompt
            }
        }
        .padding()
        .background(.ultraThinMaterial)  // Core blur
        .background(Color.white.opacity(0.05))  // Subtle tint for visibility
        .cornerRadius(15)
        .overlay(  // Gradient stroke for edge light
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(isFocused ? 0.6 : 0.3),
                            .white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: isFocused ? .cyan.opacity(0.3) : .clear, radius: 10)  // Focus glow
        .foregroundColor(.white)
        .focused($isFocused)
        #if os(iOS)
        .textInputAutocapitalization(.none)  // Fixed modifier name
        #endif
        .animation(.easeIn(duration: 0.2), value: isFocused)
    }
}

