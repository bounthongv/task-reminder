# Deployment Guide

## 1. Web Deployment (Firebase Hosting)

### Prerequisites
- Node.js and npm installed.
- Firebase CLI installed: `npm install -g firebase-tools`
- Logged into Firebase: `firebase login`

### Steps
1.  **Build the Web App:**
    Generate the release build of your Flutter web app.
    ```bash
    flutter build web
    ```

2.  **Deploy:**
    Deploy the built artifacts to Firebase Hosting.
    ```bash
    firebase deploy --only hosting
    ```

    *If you encounter issues with project selection, try:*
    ```bash
    firebase use taskreminder-480e9
    firebase deploy --only hosting
    ```
if problem:
  firebase login --reauth
  firebase deploy --only hosting
3.  **Access:**
    Your app will be available at: `https://taskreminder-480e9.web.app`

---

## 2. Windows Desktop Build

### Prerequisites
- Visual Studio 2022 with "Desktop development with C++" workload.
- Flutter configured for Windows: `flutter config --enable-windows-desktop`

### Steps
1.  **Build the Executable:**
    ```bash
    flutter build windows
    ```

2.  **Locate the File:**
    Navigate to `build/windows/x64/runner/Release/`.
    Run `task_reminder_flutter.exe`.

3.  **Distribution:**
    To distribute, you must copy the **entire** `Release` folder (containing the `.exe` and `.dll` files), not just the executable.

---

## 3. Localization

To update translations:
1.  Modify the `.arb` files in `lib/l10n/`.
2.  Run the generator:
    ```bash
    flutter gen-l10n
    ```
