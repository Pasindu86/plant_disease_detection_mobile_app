# Firebase Authentication Setup Instructions

## Enable Email/Password Authentication

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Select project: **plant-care-o1**
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Email/Password** provider
5. Enable **Google** provider (for Google Sign-In)
6. Save changes

## For Android Testing - Add SHA-1 Fingerprint

### Get Debug SHA-1:
```bash
cd android
./gradlew signingReport
```
Or on Windows:
```bash
cd android
gradlew.bat signingReport
```

### Add to Firebase:
1. Copy the SHA-1 fingerprint from the output (look for "SHA1:" under "Variant: debug")
2. In Firebase Console → Project Settings → Your apps → Android app
3. Click "Add fingerprint"  
4. Paste the SHA-1
5. Download new `google-services.json` and replace the existing one in `android/app/`
6. Rebuild the app: `flutter clean && flutter run`

## Troubleshooting Google Sign-In

### Error: "Account reauth failed" or GoogleSignInException

**This happens when SHA-1 fingerprint is not properly configured.**

**Steps to fix:**

1. **Get your SHA-1 fingerprint:**
   ```bash
   cd android
   gradlew.bat signingReport
   ```
   Look for output like:
   ```
   Variant: debug
   Config: debug
   Store: C:\Users\YourName\.android\debug.keystore
   Alias: AndroidDebugKey
   MD5: XX:XX:XX:...
   SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE
   SHA-256: ...
   ```

2. **Copy the SHA-1 value** (the long hex string after "SHA1:")

3. **Add to Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Click the gear icon ⚙️ → Project Settings
   - Scroll down to "Your apps" section
   - Click on your Android app
   - Scroll to "SHA certificate fingerprints"
   - Click "Add fingerprint"
   - Paste your SHA-1 and click "Save"

4. **Download updated google-services.json:**
   - In the same page, click "Download google-services.json"
   - Replace the file in `android/app/google-services.json`

5. **Rebuild the app:**
   ```bash
   flutter clean
   flutter run
   ```

### Additional Checks:
- ✅ Ensure Google Sign-In is enabled in Firebase Console → Authentication → Sign-in method
- ✅ Package name in Firebase matches `android/app/build.gradle.kts` (applicationId)
- ✅ SHA-1 fingerprint is from the correct keystore (debug.keystore for development)

## Verify Setup
- Test email sign-up with a new email address
- Check Firebase Console → Authentication → Users to see if account was created
