# KeepMoving

**KeepMoving** is a cross-platform productivity and wellness app built with **Flutter** and **Dart**. It helps you stay healthy, hydrated, and active while you work or study by turning your daily wellness habits into a fun, gamified experience. It was built as an individual project for the "Cross-platform Mobile Application Development" class in Autumn 2026.

---

## Features

* **Smart Focus Reminders:** Periodic prompts to drink water and take stretch breaks during your focus or work sessions.
* **Gamified Progress:**
* 💧 **Virtual Water Bottle:** Fills up a little every time you log a glass of water.
* 💪 **Muscle Stickman:** Watches your virtual stickman grow more muscular as you complete your stretch sessions!


* **Dynamic Stretch Suggestions:** Recommends different stretches tailored to the duration of your current work session.
* **Cloud Sync & Firebase Auth:** Secure sign-in and real-time data synchronization across all your logged-in devices.
* **Achievements & Levels:** Track your hydration and stretching streaks, earn achievements, and level up based on your wellness records.

---

## Platform Support

KeepMoving is fully cross-platform and supports:

* Android
* iOS
* Windows
* macOS

---

## Tech Stack

* **Framework:** Flutter (Dart)
* **Backend & Authentication:** Firebase (Firebase Auth, Firestore)

---

## Getting Started

Follow these steps to set up the project locally on your machine.

### Prerequisites

* Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* Verify your setup by running:
```bash
flutter doctor

```



### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/DominikaMendyk/KeepMoving.git
cd KeepMoving

```


2. **Install dependencies:**
```bash
flutter pub get

```


3. **Configure Firebase:**
* Set up a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
* Enable **Firebase Authentication** (Email/Password, Google, etc.).
* Configure Firebase for your target platforms using [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):
```bash
flutterfire configure

```




4. **Run the app:**
```bash
flutter run

```

