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

### Add to Firebase:
1. Copy the SHA-1 fingerprint from the output
2. In Firebase Console → Project Settings → Your apps → Android app
3. Click "Add fingerprint"
4. Paste the SHA-1
5. Download new `google-services.json` if regenerated

## Verify Setup
- Test email sign-up with a new email address
- Check Firebase Console → Authentication → Users to see if account was created
