# budget_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## AdMob Integration

This app is configured to use Google AdMob for monetization. Currently, it uses Google's test App IDs so you can develop without risking invalid traffic strikes.

Before publishing your app, you must replace these test App IDs with your actual AdMob App IDs:

**Android**
1. Open `android/app/src/main/AndroidManifest.xml`
2. Find the `<meta-data>` tag with the name `com.google.android.gms.ads.APPLICATION_ID`
3. Replace the `android:value` (`ca-app-pub-3940256099942544~3347511713`) with your real Android AdMob App ID.

**iOS**
1. Open `ios/Runner/Info.plist`
2. Find the key `GADApplicationIdentifier`
3. Replace the string value (`ca-app-pub-3940256099942544~1458002511`) below it with your real iOS AdMob App ID.
