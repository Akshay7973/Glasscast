//
//  CityResultView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI

import SwiftUI
import UIKit

struct CityResultRowView: View {
    let city: City
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading) {
                    Text(city.cityName)
                        .font(.headline)
                        .foregroundColor(.white)
                    if let country = city.countryCode {
                        Text(country)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif
                    onToggleFavorite()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .white)
                }
            }
        }
    }
}

