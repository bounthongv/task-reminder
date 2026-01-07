# Deployment Guide for Task Reminder

## Project Details
- **Firebase Project ID:** `taskreminder-480e9`
- **Hosting URL:** [https://taskreminder-480e9.web.app](https://taskreminder-480e9.web.app)
- **Configuration File:** `firebase.json` (Points to `build/web` as the public directory)

## Prerequisites
Ensure you have the Firebase CLI installed and are logged in:
```bash
npm install -g firebase-tools
firebase login
```

## How to Deploy Updates

1.  **Build the Flutter Web Application**
    Compiles the project into static files located in `build/web`.
    ```bash
    flutter build web --release
    ```
    *Note: If you encounter font or icon rendering issues, try the HTML renderer:*
    ```bash
    flutter build web --web-renderer html --release
    ```

2.  **Deploy to Firebase Hosting**
    Uploads the `build/web` directory to Firebase.
    ```bash
    firebase deploy --only hosting
    ```

## Troubleshooting
- **"Command not found":** Ensure Flutter and Firebase CLI are added to your system PATH.
- **Wrong Project:** If `firebase deploy` targets the wrong project, check `.firebaserc` or run:
    ```bash
    firebase use taskreminder-480e9
    ```
