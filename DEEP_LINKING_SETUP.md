# Deep Linking Setup for Password Reset

This document explains how to set up deep linking for the password reset functionality in your Flutter app.

## Overview

The password reset feature uses deep links to redirect users from their email back to the app. This requires proper configuration of:

1. **Android App Links** - Using `assetlinks.json`
2. **iOS Universal Links** - Using `apple-app-site-association`
3. **Flutter Deep Link Handling**

## Android App Links Setup

### 1. Create assetlinks.json

The `assetlinks.json` file has been created at `/web/.well-known/assetlinks.json`. You need to:

1. **Get your SHA256 fingerprint:**

```bash
# For debug builds (development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds (production)
keytool -list -v -keystore /path/to/your/release-keystore.jks -alias your-key-alias
```

2. **Update the assetlinks.json file** with your actual SHA256 fingerprint:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.amayalert.app",
      "sha256_cert_fingerprints": [
        "YOUR_DEBUG_SHA256_FINGERPRINT",
        "YOUR_RELEASE_SHA256_FINGERPRINT"
      ]
    }
  }
]
```

3. **Host the file** at: `https://yourdomain.com/.well-known/assetlinks.json`

### 2. Android Manifest Configuration

Add intent filters to your `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:windowSoftInputMode="adjustResize">

    <!-- Existing intent filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>

    <!-- Deep link intent filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="yourdomain.com"
              android:pathPrefix="/reset-password" />
    </intent-filter>

    <!-- Custom scheme fallback -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.amayalert.app" />
    </intent-filter>
</activity>
```

## iOS Universal Links Setup

### 1. Create apple-app-site-association

Create a file without extension at `/web/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["TEAM_ID.com.amayalert.app"],
        "components": [
          {
            "/:": "/reset-password*",
            "comment": "Password reset links"
          }
        ]
      }
    ]
  }
}
```

### 2. iOS Configuration

Add to your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.amayalert.app.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.amayalert.app</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.amayalert.app.universal</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>https</string>
        </array>
    </dict>
</array>

<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:yourdomain.com</string>
</array>
```

## Flutter App Configuration

### 1. Add dependencies to pubspec.yaml

```yaml
dependencies:
  app_links: ^3.5.0
  # ... your other dependencies
```

### 2. Deep Link Handling

Update your main app to handle incoming deep links:

```dart
// In your main.dart or router setup
class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle incoming links when app is already running
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });

    // Handle initial link when app is opened from link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/reset-password' || uri.scheme == 'com.amayalert.app') {
      // Navigate to reset password screen
      appRouter.pushAndClearStack(ResetPasswordRoute());
    }
  }
}
```

## Supabase Configuration

Update your auth provider to use the correct redirect URL:

```dart
Future<Result<String>> resetPassword({
  required String email,
}) async {
  try {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://yourdomain.com/reset-password', // Use your actual domain
    );
    return Result.success('Password reset email sent successfully');
  } catch (e) {
    return Result.error('An error occurred: ${e.toString()}');
  }
}
```

## Testing Deep Links

### 1. Test Android App Links

```bash
# Test with ADB
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "https://yourdomain.com/reset-password?token=test" \
  com.amayalert.app
```

### 2. Test iOS Universal Links

```bash
# Test with Simulator
xcrun simctl openurl booted "https://yourdomain.com/reset-password?token=test"
```

### 3. Verify assetlinks.json

Visit: `https://yourdomain.com/.well-known/assetlinks.json` in browser to ensure it's accessible.

## Deployment Steps

### 1. Web Hosting

- Upload `assetlinks.json` to `https://yourdomain.com/.well-known/assetlinks.json`
- Upload `apple-app-site-association` to `https://yourdomain.com/.well-known/apple-app-site-association`
- Ensure both files are served with correct MIME types

### 2. Supabase Configuration

- Update redirect URLs in Supabase Auth settings
- Add your domain to allowed redirect URLs
- Test email sending with new URLs

### 3. App Store Configuration

- Enable Associated Domains capability in Xcode
- Add your domain to associated domains
- Test with TestFlight builds

## Troubleshooting

### Common Issues

1. **assetlinks.json not accessible**

   - Check CORS settings
   - Verify HTTPS is working
   - Ensure file is in correct location

2. **SHA256 fingerprint mismatch**

   - Use correct keystore (debug vs release)
   - Copy fingerprint exactly (no spaces)
   - Include both debug and release fingerprints

3. **Deep links not working**
   - Check intent filter configuration
   - Verify app is set as default handler
   - Test with both custom scheme and HTTPS

### Verification Tools

- **Android**: Use Android App Links Assistant in Android Studio
- **iOS**: Use Universal Links tester tools
- **Web**: Check file accessibility with curl or browser

## Security Considerations

1. **HTTPS Required**: Both assetlinks.json and apple-app-site-association must be served over HTTPS
2. **Certificate Validation**: Ensure SSL certificates are valid
3. **Token Validation**: Verify reset tokens on the server side
4. **Rate Limiting**: Implement rate limiting for reset requests

## Next Steps

1. Get your SHA256 fingerprint using the keytool command
2. Update the assetlinks.json with your actual fingerprint
3. Host both .well-known files on your domain
4. Update your Android manifest with your domain
5. Configure iOS universal links
6. Test the complete flow end-to-end
