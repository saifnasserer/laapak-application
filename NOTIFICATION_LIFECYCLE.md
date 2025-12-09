# Notification Scheduling Lifecycle

## Overview
This document explains when and how notifications are scheduled in the Laapak mobile app.

## Notification Types

### 1. Weekly Cleaning Reminder
**When Scheduled:**
- **App Startup**: When the app initializes and notification permissions are granted
- **Location**: `lib/providers/notification_provider.dart` - `initializeNotificationsProvider`
- **Trigger**: Automatically after `notificationService.requestPermissions()` succeeds

**Schedule Details:**
- Every Monday at 10:00 AM
- Automatically reschedules after being triggered (via notification tap handler)

**Flow:**
```
App Starts → Initialize Notifications → Request Permissions → 
If Granted → Schedule Weekly Cleaning Reminder
```

### 2. Warranty Notifications (3 types)
**When Scheduled:**
- **Warranty Screen Load**: When user opens the warranty screen
- **Location**: `lib/screens/warranty/warranty_screen.dart` - `initState()` → `_scheduleWarrantyNotifications()`
- **After Permission Grant**: When user enables notifications via the button
- **Trigger**: 
  1. Screen loads (post-frame callback)
  2. User clicks "تفعيل الإشعارات" button and permission is granted

**Schedule Details:**
1. **6-Month Warranty Reminder**: 7 days before expiry
2. **First Maintenance Notification**: At 6 months from inspection date
3. **Second Maintenance Notification**: At 12 months from inspection date

**Flow:**
```
Warranty Screen Opens → Load Report Data → 
Extract Inspection Date → Schedule All 3 Warranty Notifications
```

## Permission Lifecycle

### Initial State (App Startup)
1. App starts → `initializeNotificationsProvider` runs
2. Notification service initializes
3. Permission request is attempted
4. If granted → Weekly cleaning reminder is scheduled

### User Enables Notifications (Button Click)
1. User clicks "تفعيل الإشعارات"
2. System permission dialog appears
3. User grants permission
4. Warranty notifications are scheduled (if on warranty screen)
5. Weekly cleaning reminder is scheduled

### Permission Denied
- If permanently denied → User sees instruction dialog
- Can open app settings to enable manually

## Current Behavior Summary

| Notification Type | When Scheduled | Where Scheduled | Requires Permission |
|------------------|----------------|-----------------|---------------------|
| Weekly Cleaning | App startup (if permissions granted) | `notification_provider.dart` | ✅ Yes |
| Warranty Reminder (7 days) | Warranty screen load + after permission grant | `warranty_screen.dart` | ✅ Yes |
| First Maintenance | Warranty screen load + after permission grant | `warranty_screen.dart` | ✅ Yes |
| Second Maintenance | Warranty screen load + after permission grant | `warranty_screen.dart` | ✅ Yes |

## Testing

Test buttons have been added to:
1. **Warranty Screen**: Test warranty and maintenance notifications
2. **Device Care Screen**: Test weekly cleaning notification

Use these buttons to test notification functionality without waiting for scheduled times.

## Important Notes

1. **Permissions Required**: All notifications require notification permissions to be enabled
2. **Automatic Rescheduling**: Weekly cleaning reminder automatically reschedules after being triggered
3. **One-Time Scheduling**: Warranty notifications are scheduled once per report (won't duplicate if screen is reopened)
4. **Future Dates Only**: Notifications are only scheduled if the target date is in the future

