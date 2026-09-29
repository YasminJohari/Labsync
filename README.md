# labsync

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase / Google setup

`google-services.json` contains a Firebase API key and is **not committed** to this
public repository. Before building the Android app:

1. Download the latest `google-services.json` for your Firebase project
   (Firebase Console - Project settings - Your apps - Android).
2. Use the provided template as a starting point:
   `android/app/google-services.json.example` - copy it to `android/app/google-services.json`
3. `android/app/google-services.json` is listed in `.gitignore`, so it will never
   be committed again.

> If you were using a Firebase key that was previously committed to this repo,
> **rotate/revoke it** in the Firebase / Google Cloud console so the old key stops
> working, then add the new key to your local `google-services.json`.
