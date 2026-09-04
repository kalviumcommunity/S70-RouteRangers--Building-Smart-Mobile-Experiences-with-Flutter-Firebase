# RouteHive 🐝 — Community Safety Navigation for Runners & Cyclists

[![Live Demo](https://img.shields.io/badge/Live%20Demo-route--hive--53a5e.web.app-F59E0B?style=for-the-badge&logo=firebase)](https://route-hive-53a5e.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Hosting-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

**🌐 Live Production App**: [https://route-hive-53a5e.web.app](https://route-hive-53a5e.web.app)

---

## 1. Project Overview

Traditional navigation engines prioritize speed and shortest paths. **RouteHive** shifts the focus to **safety, visibility, road surface quality, and community vigilance**. 

Through crowdsourced "hive mind" contributions, urban runners and cyclists report and monitor:
- 💡 **Night Street Lighting & Visibility**
- 🛡 **Traffic Safety & Pedestrian Comfort**
- 🚴 **Road & Footpath Surface Quality**
- 🚧 **Construction & Barricades**
- 🚫 **Temporary Road Closures**
- 🚗 **Aggressive Traffic & Blind Intersections**

---

## 2. Core Features

### 🛡 Hive Safety Dashboard (Home)
- Dynamic time-sensitive greeting (`"Good morning / afternoon / evening, Runner"`).
- Real-time **Hive Safety Snapshot** with active hazard counters and community trust index.
- Quick actions: *Explore Safe Routes*, *Report Hazard*, and *Review a Route*.
- Live feed of community hazard reports and recommended verified safe routes.

### 🗺 Interactive Map & Live Hazard Tracking (Map)
- Integrated **Google Maps SDK** with automatic user location tracking.
- Distinguishable, color-coded hazard markers (Construction, Road Closure, Poor Road, Heavy Traffic, Poor Lighting, Other).
- Tap marker to inspect reporter info, description, time ago, and community upvotes.
- **Long-Press Reporting**: Long-press anywhere on the map to trigger a sleek bottom modal pre-filled with the exact GPS coordinates.
- Photo attachment support via Camera or Gallery.

### 🔍 Route Discovery & Smart Filters (Discover)
- Browse community-curated running loops and cycling corridors.
- Search by route name, neighborhood, or tags with live filtering.
- Filter by **✓ Verified Hive** status.
- Sort by **Top Safety Rating**, **Shortest Distance**, or **Most Community Reviews**.
- Filter by condition tags (*"Well Lit"*, *"Low Traffic"*, *"Smooth Surface"*, *"Night Safe"*, etc.).

### 📍 Route Details & Hazard Warnings
- Interactive mini-map preview showing polyline paths with start/end indicators.
- Metrics breakdown: Distance (km), Estimated Time (min), Total Reviews, and Creator.
- Comprehensive ratings breakdown: **Safety & Traffic Comfort**, **Night Lighting Visibility**, and **Surface Quality**.
- Active hazard warnings along the specific route segment.
- Community review timeline with ratings, feedback comments, and tag pills.

### ⭐ 3-Metric Route Review System
- Interactive 1–5 star selectors for Safety, Lighting, and Surface.
- Multi-select route tags.
- Detailed written feedback.
- Atomic Firestore transactional recalculation of aggregate scores and dynamic **✓ Verified Hive** badge assignment.

### 👤 Profile & Hive Reputation
- Track personal contributions: *Routes Reviewed*, *Hazards Reported*, and *Hive Reputation Score*.
- Tabbed view for *My Reports* and *My Reviews*.
- Profile editing (Name, Bio, Avatar).

### ⚙️ Preferences & Resilience
- Light / Dark / System theme switching.
- Hazard alert proximity radius slider (0.5 km to 10 km).
- Resilient offline fallback and instant initial demo seeder.

---

## 3. Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (v3.41+)
- **Language**: [Dart](https://dart.dev/) (v3.11+)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Backend / Cloud Services**:
  - Firebase Authentication (`firebase_auth`, `google_sign_in`)
  - Cloud Firestore (`cloud_firestore`)
  - Firebase Cloud Storage (`firebase_storage`)
- **Location & Mapping**:
  - Google Maps Flutter (`google_maps_flutter`)
  - Geolocator (`geolocator`)
- **UI & Utilities**:
  - Typography: Google Fonts (`google_fonts` - Inter)
  - Date & Number Formatting: `intl`
  - Unique ID Generation: `uuid`
  - Preferences Storage: `shared_preferences`
  - Camera & Gallery: `image_picker`

---

## 4. Architecture & Directory Structure

Clean architecture separating data models, repository abstraction, reactive state providers, and reusable presentation components:

```
lib/
├── main.dart                          # App entry point, ProviderScope & Firebase init
├── firebase_options.dart              # Platform Firebase configuration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Hive amber, dark charcoal & status colors
│   │   ├── app_constants.dart         # Collections, hazard types & tag definitions
│   │   └── app_text_styles.dart       # Typography styles
│   ├── theme/
│   │   └── app_theme.dart             # Modern Light and Dark theme configurations
│   ├── utils/
│   │   ├── date_formatter.dart        # Relative timestamps (e.g. "3h ago")
│   │   └── geo_utils.dart             # Haversine distance & duration formatting
│   └── services/
│       ├── location_service.dart      # Geolocator permission and streams
│       └── mock_data_seeder.dart      # Starter route/hazard seeder & offline fallback
│
├── models/
│   ├── user_model.dart                # User profile & reputation model
│   ├── hazard_model.dart              # GeoPoint hazard report model
│   ├── route_model.dart               # Polyline coordinates & ratings model
│   └── review_model.dart              # Multi-metric review model
│
├── repositories/
│   ├── auth_repository.dart           # Authentication & error translation
│   ├── hazard_repository.dart         # Hazard streams, photo upload & reporting
│   ├── route_repository.dart          # Route queries & creation
│   ├── review_repository.dart         # Atomic rating calculation & verified badge logic
│   └── user_repository.dart           # Profile management
│
├── providers/
│   ├── auth_provider.dart             # User session & AuthController
│   ├── hazard_provider.dart           # Live hazards stream & filter state
│   ├── route_provider.dart            # Route list, search & sorting
│   ├── review_provider.dart           # Review streams & submission notifier
│   ├── location_provider.dart         # GPS coordinates provider
│   └── theme_provider.dart            # ThemeMode state notifier
│
├── widgets/
│   ├── custom_button.dart             # Button variants (primary, outline, danger)
│   ├── custom_text_field.dart         # Styled inputs with validation & password toggle
│   ├── star_rating_selector.dart      # Interactive & display star ratings
│   ├── hazard_badge.dart              # Color-coded hazard chip
│   ├── verified_hive_badge.dart       # Subtle '✓ Verified Hive' badge
│   ├── route_card.dart                # Discover & Home preview cards
│   ├── hazard_card.dart               # Detailed hazard card with upvoting
│   ├── empty_state_view.dart          # Friendly empty states
│   ├── error_view.dart                # Graceful error handler
│   └── hazard_report_sheet.dart       # Modal bottom sheet for long-press reporting
│
└── screens/
    ├── auth/
    │   ├── login_screen.dart          # Email & guest access
    │   ├── register_screen.dart       # Account registration
    │   └── forgot_password_screen.dart# Password reset
    ├── main_nav_screen.dart           # Bottom navigation bar
    ├── home/
    │   └── home_screen.dart           # Dashboard greeting & live snapshots
    ├── map/
    │   └── map_screen.dart            # Full-screen Google Map & marker interactions
    ├── discovery/
    │   └── discovery_screen.dart      # Route browsing, tag filters & search
    ├── route_details/
    │   └── route_details_screen.dart  # Interactive polyline preview & reviews
    ├── review/
    │   └── create_review_screen.dart  # 3-metric rating & tag selector
    ├── profile/
    │   └── profile_screen.dart        # Stats, my reports, my reviews & profile editing
    └── settings/
        └── settings_screen.dart       # Theme mode & safety radius settings
```

---

## 5. Firebase & Google Maps Setup

### A. Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password Authentication** in the Firebase Auth panel.
3. Enable **Cloud Firestore** and deploy the included `firestore.rules`:
   ```bash
   firebase deploy --only firestore:rules
   ```
4. Enable **Firebase Cloud Storage** and deploy `storage.rules`:
   ```bash
   firebase deploy --only storage:rules
   ```
5. Configure FlutterFire using the CLI:
   ```bash
   flutterfire configure
   ```
   *Or update `lib/firebase_options.dart` with your project's credentials.*

### B. Google Maps API Setup
1. Obtain an API Key from the [Google Cloud Console](https://console.cloud.google.com/) with **Maps SDK for Android** and **Maps SDK for iOS** enabled.
2. **Android**: Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```
3. **iOS**: Add the key in `ios/Runner/AppDelegate.swift` / `AppDelegate.m`.

---

## 6. Installation & Running

```bash
# 1. Clone repository
git clone https://github.com/your-username/routehive.git
cd routehive

# 2. Get dependencies
flutter pub get

# 3. Run unit tests
flutter test

# 4. Check static analysis
flutter analyze

# 5. Run on device / emulator
flutter run
```

---

## 7. Firestore Data Schema

### `users/{userId}`
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "photoUrl": "string?",
  "bio": "string",
  "routesReviewed": 14,
  "hazardsReported": 6,
  "reputationScore": 280,
  "createdAt": "Timestamp"
}
```

### `hazards/{hazardId}`
```json
{
  "id": "string",
  "userId": "string",
  "userName": "string",
  "type": "construction | road_closure | poor_road | heavy_traffic | poor_lighting | other",
  "title": "string",
  "description": "string",
  "latitude": 12.9740,
  "longitude": 77.5970,
  "location": "GeoPoint(12.9740, 77.5970)",
  "imageUrl": "string?",
  "createdAt": "Timestamp",
  "status": "active | resolved",
  "upvotes": 7
}
```

### `routes/{routeId}`
```json
{
  "id": "string",
  "creatorId": "string",
  "creatorName": "string",
  "name": "Cubbon Park Morning Loop",
  "description": "string",
  "distanceKm": 5.2,
  "durationMinutes": 34,
  "safetyRating": 4.8,
  "lightingRating": 4.6,
  "surfaceRating": 4.7,
  "reviewCount": 42,
  "isVerifiedHive": true,
  "tags": ["Well Lit", "Low Traffic", "Smooth Surface"],
  "coordinates": [
    {"latitude": 12.9756, "longitude": 77.5928},
    {"latitude": 12.9785, "longitude": 77.5950}
  ],
  "createdAt": "Timestamp"
}
```

### `reviews/{reviewId}`
```json
{
  "id": "string",
  "routeId": "string",
  "userId": "string",
  "userName": "string",
  "userPhotoUrl": "string?",
  "safetyRating": 5.0,
  "lightingRating": 4.8,
  "surfaceRating": 4.9,
  "tags": ["Well Lit", "Smooth Surface"],
  "comment": "string",
  "createdAt": "Timestamp"
}
```

---

## 8. Verified Hive Algorithm

A route is awarded the prestigious **✓ Verified Hive** badge when:
1. It accumulates **at least 3 independent reviews** (`reviewCount >= 3`).
2. Its weighted community average **Safety Rating** maintains **≥ 4.3 / 5.0**.

Ratings update atomically inside a Firestore transaction whenever a runner or cyclist submits a review.

---

## 9. License

This project is licensed under the MIT License.
