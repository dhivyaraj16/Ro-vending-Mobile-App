# 🚰 RO Vending Machine App

A complete Flutter application for RO (Reverse Osmosis) water vending machines with Firebase backend.

---

## 📱 App Screenshots / Screens

| Screen | Description |
|--------|-------------|
| Splash Screen | Animated logo screen |
| Login / Register | Email & Password auth |
| Home Dashboard | Nearby machines, wallet balance, quick actions |
| Live Map | Google Maps with machine markers |
| QR Scanner | Scan machine QR → Select litres → Pay from wallet |
| Wallet | Balance, Add Money (Razorpay), Stats |
| Transactions | Full history with filters |
| Chat / Support | Real-time support chat |
| Profile | Edit profile, Settings, Logout |

---

## 🏗 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config (auto-generated)
├── router/
│   └── app_router.dart          # GoRouter navigation
├── models/
│   └── models.dart              # User, ROmachine, Transaction, ChatMessage
├── providers/
│   ├── auth_provider.dart       # Firebase Auth
│   ├── wallet_provider.dart     # Wallet + Razorpay
│   ├── machine_provider.dart    # Firestore machines
│   ├── transaction_provider.dart
│   └── chat_provider.dart
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── main_shell.dart      # Bottom nav
│   ├── map/
│   │   └── map_screen.dart
│   ├── scanner/
│   │   └── scanner_screen.dart
│   ├── wallet/
│   │   ├── wallet_screen.dart
│   │   └── add_money_screen.dart
│   ├── transaction/
│   │   └── transaction_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart
│   └── profile/
│       ├── profile_screen.dart
│       └── edit_profile_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── machine_card.dart
│   └── stat_card.dart
└── utils/
    └── app_theme.dart           # Colors, themes
```

---

## 🚀 Setup Instructions

### Step 1: Install Flutter
```bash
flutter --version  # Ensure Flutter 3.x+
```

### Step 2: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create project: **ro-vending-machine**
3. Enable these services:
   - **Authentication** → Email/Password
   - **Firestore Database** → Start in test mode
   - **Storage** → Start in test mode
   - **Cloud Messaging** (FCM)

### Step 3: Configure FlutterFire
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In project root:
flutterfire configure
```
This will auto-generate `lib/firebase_options.dart` ✅

### Step 4: Add Google Maps API Key

**Android** → `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS** → `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

Get API key from: https://console.cloud.google.com → Maps SDK for Android/iOS

### Step 5: Add Razorpay Key
In `lib/providers/wallet_provider.dart`:
```dart
'key': 'YOUR_RAZORPAY_KEY_ID', // Replace here
```
Get from: https://dashboard.razorpay.com

### Step 6: Android Permissions
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

### Step 7: iOS Permissions
`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera needed to scan QR codes</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location needed to show nearby machines</string>
```

### Step 8: Install Dependencies
```bash
flutter pub get
```

### Step 9: Seed Machine Data
1. Go to Firebase Console → Firestore
2. Create `machines` collection
3. Add documents from `seed_data.js` (sample data provided)
4. Each machine needs: `machineCode` field for QR scanning

### Step 10: Upload QR Codes to Machines
Each machine has a `machineCode` (e.g., `RO-AN-001`).
Generate QR codes from: https://qr-code-generator.com
Print and stick on physical machines.

### Step 11: Run
```bash
flutter run
```

---

## 🔥 Firebase Collections

### `users/{userId}`
```json
{
  "uid": "abc123",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+919876543210",
  "walletBalance": 250.0,
  "createdAt": "timestamp"
}
```

### `machines/{machineId}`
```json
{
  "id": "machine001",
  "name": "RO Station - Anna Nagar",
  "address": "Chennai",
  "latitude": 13.0891,
  "longitude": 80.2126,
  "isOnline": true,
  "isAvailable": true,
  "pricePerLitre": 1.0,
  "machineCode": "RO-AN-001",
  "totalWaterDispensed": 1250.5
}
```

### `transactions/{txId}`
```json
{
  "userId": "abc123",
  "machineId": "machine001",
  "type": "waterPurchase",
  "status": "success",
  "amount": 2.0,
  "litresDispensed": 2.0,
  "createdAt": "timestamp"
}
```

### `chats/{userId}/messages/{msgId}`
```json
{
  "senderId": "abc123",
  "message": "Machine not working",
  "timestamp": "timestamp",
  "isSupport": false
}
```

---

## 🔒 Firestore Security Rules
Copy from `firestore.rules` to Firebase Console → Firestore → Rules

---

## 🛠 Tech Stack

| Technology | Usage |
|-----------|-------|
| Flutter 3.x | Cross-platform UI |
| Firebase Auth | Email/Password login |
| Cloud Firestore | Real-time database |
| Firebase Storage | Profile photos |
| FCM | Push notifications |
| Google Maps | Live machine locator |
| Razorpay | Payment gateway |
| mobile_scanner | QR code scanning |
| Provider | State management |
| GoRouter | Navigation |

---

## 📞 Support
For any issues, contact: support@rovendingmachine.com
