//
//  ForecastCardView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI

import SwiftUI

struct ForecastCardView: View {
    let weather: Weather
    let unit: String
    
    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text(weather.dayName)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Image(systemName: weather.weatherCondition.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("\(Int(weather.tempMax))°")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(Int(weather.tempMin))°")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 70)
        }
    }
}

//#Preview {
//    ForecastCardView()
//}
