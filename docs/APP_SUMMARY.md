# Task Reminder - Application Summary

A feature-rich, cross-platform task management application built with Flutter, designed for seamless synchronization and high accessibility across different languages and visual styles.

## 🚀 Key Features

### 1. Task Management
*   **Full CRUD:** Create, Read, Update, and Delete tasks easily.
*   **Recurrence:** Support for repeating tasks (minutes, hours, days).
*   **Smart Organization:** Sort by Due Date, Title, or Status; Filter by All, Pending, Overdue, or Completed.
*   **Data Portability:** Export and download your task list as a JSON file (Web feature).

### 2. Intelligent Notifications
*   **Audio Alerts:** Plays a notification sound (`notification.mp3`) when a task is due.
*   **Visual Prompts:** Real-time SnackBar alerts for upcoming or overdue tasks.
*   **Background Check:** Periodic timer checks task status every minute.

### 3. Personalization & Localization
*   **Advanced Theming:** Choose from 6 visual modes:
    *   System Default, Bright, Dark, Ocean, Forest, and Sunset.
*   **Multi-Language Support:** Fully localized for:
    *   English, Lao, German, Russian, and Thai.
*   **Custom Typography:** Includes `NotoSansLao` for perfect rendering of Lao script.

### 4. Security & Cloud Sync
*   **Real-time Sync:** Powered by **Firebase Firestore**.
*   **Secure Auth:** Integration with **Firebase Authentication**, including **Google Sign-In**.

## 📱 Supported Platforms

The application is built using Flutter's multi-platform capabilities and includes configurations for:

| Platform | Support Level | Hosting/Distribution |
| :--- | :--- | :--- |
| **Web** | Full (Primary) | Hosted on Firebase |
| **Android** | Full | Native Android App |
| **iOS** | Full | Native iOS App |
| **Windows** | Full | Native Desktop App |
| **macOS** | Full | Native Desktop App |
| **Linux** | Full | Native Desktop App |

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **State Management:** Provider
- **Backend/Database:** Firebase Firestore
- **Authentication:** Firebase Auth
- **Hosting:** Firebase Hosting
- **Internationalization:** Flutter Intl (ARB files)
