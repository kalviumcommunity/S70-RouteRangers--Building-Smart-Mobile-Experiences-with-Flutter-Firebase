# RouteHive 🐝

RouteHive is a community-driven navigation app for urban runners and cyclists. While traditional GPS apps prioritize the fastest route, RouteHive focuses on the safest and most reliable ones by leveraging the "hive mind"—real-time crowdsourced reviews on lighting, traffic, and surface quality.

## 🚀 Key Features

- **Safety Micro-Reviews:** Rate route segments on a scale of 1-5 for safety and lighting.
- **Live Hazard Pins:** Drop real-time markers for construction, road closures, or poor conditions.
- **Verified Hives:** Discover routes curated and endorsed by local athletic communities.
- **Real-time Sync:** Powered by Firebase for instant community updates.

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Auth, Storage)
- **Maps:** Google Maps SDK for Flutter
- **State Management:** Provider / Riverpod (Choose your preference)

## 📅 4-Week Roadmap

### Week 1: Foundation & Auth
- Project initialization and Firebase integration.
- User Authentication (Email/Google Sign-in).
- Basic UI layout and Navigation setup.
- **Goal:** A working app where users can log in and see a blank map.

### Week 2: Map Integration & Pinning
- Implement Google Maps SDK.
- Create the Hazard model and Firestore collection.
- Enable "Long-press to Pin" functionality for reporting hazards.
- **Goal:** Users can see their location and drop pins that persist in the database.

### Week 3: Route Discovery & Reviews
- Implement Route and Review data structures.
- Build the Discovery Feed to browse community-vetted paths.
- Develop the review submission form (Star ratings + Tags).
- **Goal:** Users can view existing routes and submit qualitative feedback.

### Week 4: Polishing & Deployment
- UI/UX Refinement (Custom Hive-themed markers and icons).
- Offline caching for map data.
- Bug fixing and performance optimization.
- **Goal:** A polished, presentable MVP ready for demo.

## 🏁 Getting Started

1. **Clone the repo:**
   ```bash
   git clone https://github.com/yourusername/route-hive.git
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Create a project in the [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS apps and download `google-services.json` / `GoogleService-Info.plist`.
   - Place them in the respective `android/app` and `ios/Runner` directories.

4. **Run the app:**
   ```bash
   flutter run
   ```
