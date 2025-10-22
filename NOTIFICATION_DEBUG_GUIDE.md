# 🔔 Notification Debugging Guide

## Problem
Notifications are not working on Android emulator.

## What We Did

### 1. Added Debugging Tools ✅
Created `lib/utils/notification_debug.dart` with:
- `testNotification()` - Send a test notification manually
- `checkPermissions()` - Check if permissions are granted and FCM token exists
- `showDebugInfo()` - Show a dialog with notification status

### 2. Added Public Helper Methods to NotificationService ✅
- `getFCMToken()` - Get the Firebase Cloud Messaging token
- `hasPermission()` - Check if notification permissions are granted

## How to Debug Notifications

### Step 1: Add Debug Button to Your App

Add this to any screen (e.g., Settings tab):

```dart
import '../utils/notification_debug.dart';

// In your build method:
ElevatedButton(
  onPressed: () => NotificationDebug.showDebugInfo(context),
  child: const Text('🔔 Test Notifications'),
),
```

### Step 2: Check the Debug Info

When you tap the button, you'll see:
- ✅ **Has Permission**: true/false
- ✅ **FCM Token**: true/false (whether token was obtained)
- ✅ **Token Value**: First 20 characters of the token

### Step 3: Send Test Notification

From the debug dialog, tap "Send Test" to send a test notification.

## Common Issues & Solutions

### Issue 1: Permission Not Granted
**Solution**: The app should ask for permission on first launch. If it didn't:
1. Uninstall the app
2. Reinstall and run again
3. Grant notification permission when prompted

### Issue 2: No FCM Token
**Possible causes**:
1. **Firebase not initialized** - Check console for "✅ Firebase initialized successfully"
2. **google-services.json missing** - File exists at `android/app/google-services.json` ✅
3. **Network issue** - Firebase needs internet to get token

**Solution**: Check the console logs when app starts:
```
🔔 Initializing NotificationService...
✅ Firebase initialized successfully
✅ Local notifications initialized
✅ Permissions requested
✅ FCM token obtained
✅ Message handlers setup
✅ NotificationService initialization completed
```

### Issue 3: Notifications Not Appearing
**Possible causes**:
1. **Android emulator issues** - Some emulators don't show notifications properly
2. **Notification channel not created** - Already handled in code ✅
3. **App in foreground** - Notifications might not show when app is open

**Solution**:
1. Test on a real Android device
2. Put app in background and send notification
3. Check Android notification settings for the app

## Testing Checklist

- [ ] App asks for notification permission on first launch
- [ ] Debug info shows "Has Permission: true"
- [ ] Debug info shows "FCM Token: true"
- [ ] Test notification appears in notification tray
- [ ] Notification makes sound/vibration
- [ ] Tapping notification opens the app

## Console Logs to Look For

### Success Logs:
```
🔔 Initializing notification services...
🔔 Initializing NotificationService...
✅ Firebase initialized successfully
✅ Local notifications initialized
✅ Permissions requested
✅ FCM token obtained
✅ Message handlers setup
✅ NotificationService initialization completed
✅ All notification services initialized
```

### Error Logs to Watch For:
```
❌ NotificationService initialization failed: ...
❌ Failed to get FCM token: ...
❌ Failed to request permissions: ...
⚠️ Firebase initialization failed (web platform): ...  [This is OK for web]
```

## Quick Test Code

You can also test notifications directly from Dart DevTools console:

```dart
import 'package:chizo/services/notification_service.dart';

// Send test notification
await NotificationService.sendLocalNotification(
  title: '🎉 Test',
  body: 'This is a test notification',
  type: 'test',
  data: {},
);
```

## Next Steps

1. **Add the debug button** to your Settings screen
2. **Run the app** on Android emulator
3. **Check console logs** for initialization messages
4. **Tap the debug button** and check the info
5. **Send a test notification** and verify it appears
6. **Report back** what you see!

## Files Modified

1. `lib/utils/notification_debug.dart` - New debugging utilities ✅
2. `lib/services/notification_service.dart` - Added public helper methods ✅
3. `NOTIFICATION_DEBUG_GUIDE.md` - This guide ✅

---

**Note**: Notification system is already properly configured with:
- ✅ Firebase integration
- ✅ Google Services JSON file
- ✅ Android permissions in manifest
- ✅ Notification channels
- ✅ Background message handling

The issue is likely just a permission or emulator problem!
