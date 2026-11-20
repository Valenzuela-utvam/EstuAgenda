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
- `tasks/{taskId}` stores tasks, due dates/times, and status for a subject.
- `classes/{classId}` stores the weekly schedule associated with a subject.
- `calendarTasks/{taskId}` stores dated calendar entries.
- `settings/preferences` stores each user's task-reminder lead time.

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

## Wear OS companion app

The calendar combines dated tasks from **Materias y Tareas** with entries
created directly in **Calendario**. The Wear OS app lives in
`android/wearable`; the Flutter phone app sends the signed-in user's upcoming
tasks and calendar entries to a paired Android watch through the Wear OS Data
Layer. Tasks in **Materias y Tareas** require a due date and time. The reminder
lead time is configured in **Configuraciones → Avisos de tareas** and is saved
per account. Options are 10, 15, 30 minutes, 1, 2, 3, or 4 hours, or 1 day
before; the default is 1 day. Firebase credentials are not copied to the watch.
Android may use an inexact alarm if the user has not allowed exact alarms, and
notifications require the watch's notification permission.

Tasks created before due dates were added can still be viewed, but edit each one
and set its due date and time before it can appear on the watch.

After changing Firestore rules or adding task fields, publish the current
`firestore.rules` from **Firestore Database → Rules** in Firebase Console.

Build the phone app with `flutter run` from this directory. Build the watch APK
with `cd android && ./gradlew :wearable:assembleDebug`, then install it on a
Wear OS emulator or paired watch. For development, pair the phone and watch
emulators in Android Studio's Device Manager. Both apps must use the same
package name (`com.example.estu_agenda`) and application signing certificate
for Data Layer communication. Debug builds use the local Android debug
certificate; release builds must be signed with the same release certificate.
