# Glasscast - AI Development Context

## Project Overview
Weather app with iOS 26 Liquid Glass design, Supabase backend, and OpenWeatherMap API.

## Tech Stack
- SwiftUI (iOS 26+)
- Supabase (Auth + Database)
- OpenWeatherMap API
- MVVM Architecture

## Design System
- iOS 26 Liquid Glass (.glassEffect(), GlassEffectContainer)
- Color Palette: Sky blues, soft purples, translucent whites
- Typography: SF Pro (system font)
- Animations: Smooth, physics-based

## Architecture Rules
1. MVVM pattern strictly
2. ViewModels use @MainActor
3. Async/await for all API calls
4. Combine for reactive updates
5. No force unwrapping (use guard/if let)

## Code Style
- SwiftLint compliant
- Descriptive variable names
- Comments for complex logic
- Error handling with Result types

## API Keys & Secrets
- Use .env or Info.plist (NOT in code)
- Add to .gitignore

## ✨ Features
- 🌤️ Current + dynamic SF icons
- 📅 5-day forecast (fixed)
- 📍 GPS location (no leaks)
- ⭐ Supabase favorites
- 🎨 iOS 18 MeshGradient glass UI

## 🚀 Setup (5 min)

1. **Clone**
```bash
https://github.com/Akshay7973/Glasscast.git
cd Glasscast && open Glasscast.xcodeproj

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
