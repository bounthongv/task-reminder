# Task Reminder Application Features

## Overview
The Task Reminder App is a robust, cross-platform productivity tool designed to help users manage their daily tasks efficiently. Built with Flutter, it ensures a seamless experience across 6 platforms with a single codebase: Web, Android, iOS, Windows, macOS, and Linux, backed by real-time cloud synchronization via Firebase.

## Key Features

### 1. Advanced Task Management
*   **Comprehensive Task Creation:** Create tasks with rich metadata including:
    *   **Title & Description:** Clear identification and detailed notes for every objective.
    *   **Due Date & Time:** Precise scheduling to ensure nothing is missed.
*   **Flexible Repetition Options:** Automate your workflow with advanced recurrence settings:
    *   **Custom Intervals:** Set tasks to repeat every $X$ amount of time.
    *   **Multiple Units:** Choose between **Minutes**, **Hours**, or **Days** for the repetition frequency.
    *   **Automatic Renewal:** Once a recurring task is completed, a new instance is automatically created based on the defined interval.
*   **Dynamic Status Tracking:** Tasks are automatically categorized into four states:
    *   **Pending:** Tasks currently in progress or awaiting their due date.
    *   **Completed:** Successfully finished tasks.
    *   **Overdue:** Tasks that have passed their due date without being marked as complete.
*   **Powerful Filtering & Sorting:** Stay organized regardless of how many tasks you have:
    *   **Filter by Status:** Instantly toggle between viewing **All**, **Pending**, **Overdue**, or **Completed** tasks to focus on what matters most.
    *   **Multi-Criteria Sorting:** Organize your list by **Due Date** (to see what's next), **Status** (to group by progress), or **Title** (for alphabetical organization).

### 2. User Experience & Customization
*   **Multi-Language Support:** Fully localized interface supporting 5 languages:
    *   English
    *   Lao
    *   Thai
    *   German
    *   Russian
*   **Rich Theming:** Personalize the app look and feel with 6 distinct themes:
    *   **System:** Adapts to your device's mode.
    *   **Bright:** Clean, light interface.
    *   **Dark:** Easy on the eyes for low-light usage.
    *   **Ocean:** Calming blue tones.
    *   **Forest:** Refreshing green shades.
    *   **Sunset:** Warm orange and purple hues.

### 3. Desktop Integration
*   **System Tray:** Application runs in the background with a system tray icon for quick access.
*   **Native Notifications:** Receive desktop notifications with custom sounds (Chime, Beep) when tasks are due.
*   **Window Management:** Remembers window size and position for a consistent workspace.

### 4. Security & Cloud Sync
*   **Secure Authentication:**
    *   Email/Password Registration & Login.
    *   Google Sign-In integration.
*   **Real-time Synchronization:** All tasks are stored securely in Google Cloud Firestore, ensuring your data is always up-to-date across all your devices.

### 5. Utilities
*   **Export Data:** Download your task list as a JSON file (Web only) for backup or external use.
*   **Offline Capability:** (Planned/Implicit via Flutter) view UI elements even when offline.

## Technical Highlights
*   **Framework:** Flutter (Dart).
*   **Backend:** Firebase (Auth, Firestore).
*   **State Management:** Provider.
*   **Platform Support:** Single codebase supporting 6 platforms: Android, iOS, Web, Windows, macOS, and Linux.
