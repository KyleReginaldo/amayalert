# Forgot Password Feature

This document describes the implementation of the forgot password functionality in the Amayalert Flutter application.

## Overview

The forgot password feature allows users to reset their password when they can't remember it. The process involves sending a password reset email to the user's registered email address, which contains a link to reset their password.

## Implementation Details

### Files Added/Modified

1. **lib/feature/auth/forgot_password_screen.dart** (NEW)

   - Main UI screen for initiating password reset
   - Email input and validation
   - Success state management
   - Resend functionality

2. **lib/feature/auth/reset_password_screen.dart** (NEW)

   - Screen for setting new password from email link
   - Password validation and confirmation
   - Security tips display

3. **lib/feature/auth/auth_provider.dart** (MODIFIED)

   - Added `resetPassword()` method for sending reset emails
   - Added `updatePassword()` method for updating password from reset flow

4. **lib/feature/auth/sign_in_screen.dart** (MODIFIED)

   - Updated "Forgot password?" button to navigate to forgot password screen
   - Added proper route import

5. **lib/core/router/app_route.dart** (MODIFIED)

   - Added ForgotPasswordRoute and ResetPasswordRoute configurations

6. **test/forgot_password_test.dart** (NEW)
   - Unit tests for forgot password functionality

## User Flow

### 1. Initiate Password Reset

1. User taps "Forgot password?" on sign-in screen
2. User enters email address on forgot password screen
3. User taps "Send Reset Email"
4. System sends password reset email via Supabase
5. Success message is shown with option to resend

### 2. Complete Password Reset

1. User receives email with reset link
2. User clicks link (opens reset password screen)
3. User enters new password and confirmation
4. User taps "Update Password"
5. Password is updated via Supabase
6. Success dialog is shown

## Features

### Forgot Password Screen

- **Email Input**: Validated email field with proper keyboard type
- **Send Button**: Sends reset email via Supabase
- **Success State**: Shows confirmation and allows resending
- **Instructions**: Clear guidance on what happens next
- **Resend Functionality**: Allows users to request another email
- **Navigation**: Easy return to sign-in screen

### Reset Password Screen

- **New Password Field**: Secure input with visibility toggle
- **Confirm Password Field**: Matching validation
- **Security Tips**: Best practices for password creation
- **Update Button**: Completes the password reset process
- **Success Dialog**: Confirms successful password update

### Validation Rules

- Email must be valid format
- Password must be at least 6 characters
- Confirm password must match new password

## Technical Implementation

### AuthProvider Methods

#### resetPassword()

```dart
Future<Result<String>> resetPassword({
  required String email,
}) async {
  // Sends password reset email via Supabase
  // Returns success/error result
}
```

#### updatePassword()

```dart
Future<Result<String>> updatePassword({
  required String newPassword,
}) async {
  // Updates user password via Supabase
  // Returns success/error result
}
```

### Navigation Flow

```
SignInScreen → ForgotPasswordScreen
Email Link → ResetPasswordScreen → Success → SignInScreen
```

### Deep Link Configuration

The reset password email includes a redirect URL:

```dart
redirectTo: 'com.amayalert.app://reset-password'
```

This should be configured in your app's deep link handling to navigate to the ResetPasswordScreen.

## Security Considerations

1. **Email Verification**: Only registered email addresses can receive reset links
2. **Token Expiry**: Supabase manages token expiration for security
3. **Single Use**: Reset tokens are typically single-use
4. **HTTPS**: All communication is encrypted via Supabase
5. **No Password Exposure**: Current passwords are never displayed or logged

## Error Handling

The system handles various error scenarios:

- Invalid email addresses
- Non-existent user accounts
- Network connectivity issues
- Expired reset tokens
- Supabase authentication errors

### Common Error Messages

- "Please enter a valid email address"
- "Password must be at least 6 characters"
- "Passwords do not match"
- "An error occurred: [specific error]"

## Testing

Basic unit tests are provided in `test/forgot_password_test.dart`. For comprehensive testing, consider:

- Integration tests for the full reset flow
- UI tests for form validation
- Error scenario testing
- Email delivery testing (manual)
- Deep link navigation testing

## Setup Requirements

### Supabase Configuration

1. Ensure your Supabase project has email templates configured
2. Set up SMTP settings for email delivery
3. Configure redirect URLs in Supabase Auth settings
4. Add the deep link redirect URL: `com.amayalert.app://reset-password`

### Deep Link Setup

1. Configure URL schemes in iOS (Info.plist)
2. Configure intent filters in Android (AndroidManifest.xml)
3. Handle incoming deep links in your app router

### Email Template Customization

Customize the password reset email template in your Supabase dashboard:

- Add your app branding
- Customize the message text
- Ensure the reset link is prominent

## Dependencies

This feature relies on:

- Supabase Flutter for authentication and email sending
- Auto Route for navigation
- Flutter EasyLoading for user feedback
- Lucide Icons for UI icons

## Future Enhancements

Potential improvements:

1. Custom email templates with app branding
2. Multiple email provider support
3. SMS-based password reset option
4. Rate limiting for reset requests
5. Admin dashboard for monitoring reset requests
6. Integration with customer support systems
7. Password strength meter
8. Biometric authentication setup after reset

## Troubleshooting

### Email Not Received

1. Check spam/junk folder
2. Verify email address is correct
3. Check Supabase email delivery logs
4. Verify SMTP configuration

### Deep Link Not Working

1. Verify URL scheme configuration
2. Test deep link handling
3. Check router configuration
4. Verify redirect URL in Supabase

### Reset Not Working

1. Check token expiry
2. Verify user session state
3. Check Supabase auth logs
4. Verify network connectivity
