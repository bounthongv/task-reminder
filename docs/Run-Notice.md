* run as windows desktop
flutter run -d windows

* build windows desktop
flutter build windows

* save in : build\windows\x64\runner\Release\

* run web
flutter run -d chrome

* build web
flutter build web

* upload web to firebase
firebase deploy --only hosting

* need to fix port in the code and then make whitelist on firebase 
* currently we use port 5000


Here is a concise summary suitable for your project's **README.md** or **Developer Manual**.

***

## Google Authentication Setup (Web)

To successfully run Google Sign-In locally, the application requires a fixed port to match the Google Cloud Console allowlist.

### 1. Google Cloud Console Configuration
1.  Navigate to **[Google Cloud Console > APIs & Services > Credentials](https://console.cloud.google.com/apis/credentials)**.
2.  Open the **OAuth 2.0 Client ID** (Web client).
3.  Under **Authorized JavaScript origins**, ensure the following is added:
    *   `http://localhost:5000`

### 2. Project Configuration
1.  Copy the **Client ID** from the Google Cloud Console.
2.  Open `web/index.html` in your Flutter project.
3.  Add the following meta tag inside the `<head>` section:
    ```html
    <meta name="google-signin-client_id" content="YOUR_PASTED_CLIENT_ID">
    ```

### 3. Running the App Locally
Because Google OAuth restricts dynamic ports, you must run the application on the specific allowed port (**5000**).

**Using Terminal:**
```bash
flutter run -d chrome --web-port 5000
```

**Using VS Code (launch.json):**
Add the args to your debug configuration:
```json
{
    "name": "taskreminder (Chrome)",
    "request": "launch",
    "type": "dart",
    "args": ["--web-port", "5000"]
}
```
