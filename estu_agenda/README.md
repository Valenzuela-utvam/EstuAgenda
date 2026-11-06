# estu_agenda

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

## Firebase Data

The app stores each account's data in Cloud Firestore under `users/{uid}`:

- `subjects/{subjectId}` stores each subject.
- `tasks/{taskId}` stores tasks and their status for a subject.
- `classes/{classId}` stores the weekly schedule associated with a subject.
- `calendarTasks/{taskId}` stores dated calendar entries.

Create a Cloud Firestore database in the Firebase project and publish the
updated rules from `firestore.rules` in **Firestore Database → Rules**. The app
only grants a signed-in user access to data under their own UID. In **Materias
y Tareas**, subjects and tasks sync automatically; the weekly schedule on the
home screen also saves and reloads from Firestore.

### Firebase configuration and secrets

The Firebase API keys and app IDs in `lib/firebase_options.dart` are public
client configuration required by Firebase SDKs; they are not admin credentials
and moving them to a Flutter `.env` file would not make them secret because
client assets are included in the app. Keep this generated file versioned so
other builds can initialize Firebase. Restrict its API key in Google Cloud
Console and protect data with Firebase Authentication and Firestore rules.

`google-services.json`, `GoogleService-Info.plist`, `.env` files, signing keys,
and Firebase Admin service-account JSON files are ignored by Git. Never put
Firebase Admin credentials or other private keys in the Flutter app. When
setting up a local copy, obtain the platform configuration from the Firebase
project owner and run `flutterfire configure` to generate the local Firebase
configuration.
