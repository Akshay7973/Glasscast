# Glasscast

[![SwiftUI](https://img.shields.io/badge/SwiftUI-18.0-orange.svg)](https://developer.apple.com/xcode/swiftui/)
[![iOS](https://img.shields.io/badge/iOS-18.0-blue.svg)](https://developer.apple.com/ios/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-purple.svg)](https://supabase.com)
[![Location](https://img.shields.io/badge/Location-GPS-green.svg)](https://developer.apple.com/core-location/)

# Glasscast

**Modern SwiftUI weather app** with GPS location, 5-day forecast, favorite cities (Supabase), and stunning **glassmorphism UI**. Built for iOS 18+.

![Hero Shot](https://via.placeholder.com/430x930/1e3a8a/ffffff?text=🧊+Glasscast)

## ✨ **Features**
| 🌤️ Current Weather | 📅 5-Day Forecast | 📍 GPS Location |
|---|---|---|
| Dynamic SF Symbols | Horizontal scroll | Async/await (no leaks) |
| Feels-like temp | High/low daily | Permission handling |

| ⭐ Favorites | 🎨 Glass UI | ⚙️ Settings |
|---|---|---|
| Supabase sync | MeshGradient | °C/°F toggle |
| Search cities | Custom navbar | Pull-to-refresh |

## 🚀 **Quick Start** (5 Minutes)

### 1. Clone & Open
```bash
git clone https://github.com/Akshay7973/Glasscast.git
cd Glasscast
open Glasscast.xcodeproj


2. Get API Keys

Supabase dashboard.supabase.com:

text
SUPABASE_URL=https://xyz.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
OpenWeatherMap openweathermap.org/api:

text
OPENWEATHER_API_KEY=1234567890abcdef...
3. Create Config.plist (gitignore'd)

text
Xcode → Right-click Glasscast → New File → Property List → "Config.plist"
xml
<key>SUPABASE_URL</key>
<string>https://your-project.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>eyJ...</string>
<key>OPENWEATHER_API_KEY</key>
<string>123456...</string>
4. Supabase Table

Dashboard → SQL Editor:

sql
CREATE TABLE favorite_cities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL, 
  lon DOUBLE PRECISION NOT NULL,
  country TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
5. Run App

text
⌘+R → iPhone 16 Pro (iOS 18.2)
Simulator → Features → Location → Custom Location
Pune: Lat 18.5204, Lon 73.8567
