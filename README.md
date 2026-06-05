# Budget App

A Flutter application designed to help users track their budget, manage transactions, and seamlessly import bank records using machine learning.

## What it does

Budget App is a personal finance tool that allows users to monitor their spending against budget categories. It simplifies data entry by providing a "Smart Text Import" feature. Instead of manually entering each transaction, users can paste multi-line text (e.g., copied directly from their bank's website or app), and the app uses Google ML Kit to automatically extract the transaction dates, amounts, and infer the appropriate categories based on user-defined rules.

## Features Currently Implemented

*   **Budget Dashboard:** A customizable dashboard to view budget categories and subcategories. Users can view their budget based on different cycles (Weekly, Fortnightly, Monthly) and customize the start day of the week.
*   **Transaction Management:** View, add, and edit individual financial transactions.
*   **Smart Text Import:** Paste raw, multi-line text from bank statements. The app parses the text using Google ML Kit Entity Extraction to identify dates and money amounts.
*   **Auto-Categorization Rules:** Automatically assign imported transactions to specific categories and subcategories based on custom keyword matching rules.
*   **Data Backup & Restore:** Export all app data and settings to a ZIP file for safekeeping, and restore from it when needed.
*   **AdMob Integration:** The app is configured with Google AdMob for monetization (currently using test IDs).

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
