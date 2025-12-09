# Google Play Data Safety Form - Answer Guide

This guide helps you complete the Data Safety section in Google Play Console.

## Answer: **YES** ✅ (But with important clarification)

Your app **DOES have access to** user data types, but collection is **minimal** - primarily what's needed for login functionality.

## ⚠️ Important Clarification

**What the app does:**
- User enters phone number + order code to login
- App receives client data (name, phone, etc.) from your server
- App stores this data locally on device for session management
- App does NOT track analytics
- App does NOT automatically collect usage behavior
- App does NOT send data to third-party analytics services

**What Google Play considers "data collection":**
- Any data the app has access to or stores, regardless of whether you actively "collect" it
- Even if data is just used for app functionality

---

## 📋 Data Types Your App Collects

### 1. Personal Info
**✅ YES - Collect this data type**

#### What data:
- ✅ **Name** (user's full name from client profile)
- ✅ **Phone number** (for authentication and account)
- ✅ **Email address** (if provided by user)
- ✅ **Address** (if provided by user)

#### Purpose:
- ✅ **App functionality** (required for account access and service delivery)
- ✅ **Account management** (identifying users and managing their accounts)

#### Collection method:
- ✅ **Provided by user** (user enters during login/registration)
- ✅ **Collected automatically** (from server when user logs in)

#### Sharing:
- ❌ **Not shared with third parties** (unless you use third-party services)

#### Required or optional:
- **Phone number & Order code:** Required (for login)
- **Name:** Required (from server)
- **Email & Address:** Optional (if available)

---

### 2. Financial Info
**✅ YES - Collect this data type** (if users make purchases)

#### What data:
- ✅ **Purchase history** (orders placed through WooCommerce)

#### Purpose:
- ✅ **App functionality** (processing orders and displaying order history)

#### Collection method:
- ✅ **Collected automatically** (when orders are placed)

#### Sharing:
- ✅ **Shared with:** WooCommerce/WordPress (for order processing)

#### Required or optional:
- Optional (only if user makes purchases)

---

### 3. Authentication Info
**✅ YES - Collect this data type**

#### What data:
- ✅ **Credentials** (JWT authentication tokens)
- ✅ **Order codes** (used for login authentication)

#### Purpose:
- ✅ **App functionality** (user authentication and session management)
- ✅ **Security** (verifying user identity)

#### Collection method:
- ✅ **Provided by user** (order code entered during login)
- ✅ **Collected automatically** (JWT token received from server)

#### Sharing:
- ❌ **Not shared with third parties**

#### Required or optional:
- Required for app functionality

---

### 4. App Activity
**❌ NO - You can skip this** (unless you actually track it)

#### Important:
- Your app does **NOT** track user interactions automatically
- Your app does **NOT** have analytics or tracking code
- App activity data is **NOT** collected or stored

#### If Google Play asks anyway:
- Some apps show this as optional
- If required, you can say "No" if you truly don't track activity
- OR if you must answer, say minimal collection only for app functionality

---

### 5. Device or Other IDs
**✅ YES - Collect this data type**

#### What data:
- ✅ **Device ID** (for identifying device)
- ✅ **Device information** (model, OS version for reports)

#### Purpose:
- ✅ **App functionality** (device reports and diagnostics)
- Note: No crash reporting or analytics tools are used

#### Collection method:
- ✅ **Collected automatically** (by Android/Flutter system, not by your code)

#### Sharing:
- ❌ **Not shared with third parties** (no crash reporting services)

---

## ❌ Data Types Your App Does NOT Collect

- **Location:** No location data collected
- **Photos:** No photo collection (only viewing)
- **Videos:** No video collection (only viewing)
- **Audio:** No audio data collected
- **Files and docs:** No file collection (only viewing/sharing)
- **Calendar:** No calendar access
- **Contacts:** No contacts access
- **Health and fitness:** Not applicable
- **Messages:** Not applicable

---

## 🔒 Data Security Practices

When completing the Data Safety form, you should indicate:

### Encryption:
- ✅ **Data is encrypted in transit** (HTTPS/TLS)
- ✅ **Data is encrypted at rest** (Flutter Secure Storage with encrypted SharedPreferences)

### Data deletion:
- ✅ **Users can request deletion** (through logout or deleting app)
- ✅ **Data deletion process:** Clear all stored data from device when user logs out or deletes app

---

## 📝 Step-by-Step Form Answers

### Question 1: "Does your app collect or share any of the required user data types?"
**Answer: YES** ✅

**Why?** Even though you just login, the app:
- Receives personal info from server (name, phone)
- Stores authentication tokens locally
- Accesses device information (automatic by Android system)

### Question 2: For each data type collected:
1. **Personal Info:**
   - ✅ Collected: YES
   - **What:** Name, phone number (received from your server after login)
   - **How:** User provides phone + order code → Server returns client data → App stores locally
   - Purpose: App functionality, Account management
   - Collection: Received from server (not actively "collected" by app)
   - Sharing: No
   - Required: Yes (needed for app to function)

2. **Financial Info (if applicable):**
   - ✅ Collected: YES (if WooCommerce orders enabled)
   - Purpose: App functionality
   - Collection: Automatic
   - Sharing: Yes - WooCommerce/WordPress
   - Required: No

3. **Authentication Info:**
   - ✅ Collected: YES
   - **What:** Order code (user enters), JWT token (received from server)
   - **How:** User enters order code → Server returns JWT token → App stores token locally
   - Purpose: App functionality, Security (session management)
   - Collection: User-provided (order code) + Received from server (token)
   - Sharing: No
   - Required: Yes (required for login)

4. **App Activity:**
   - ❌ **Collected: NO** (Skip this section if possible)
   - **Why:** Your app does NOT track user activity or screen views
   - **If Google Play requires it:** Select "No" or minimal collection for app functionality only

5. **Device or Other IDs:**
   - ✅ Collected: YES (by Android system automatically)
   - **What:** Device information (model, OS) - accessed automatically by Flutter/Android
   - **How:** System provides this automatically (not actively collected by your code)
   - Purpose: App functionality (may be used in API calls for device reports)
   - Collection: Automatic (by Android/Flutter framework)
   - Sharing: No
   - Required: No (system provides it)

### Question 3: Data Security
- ✅ **Is data encrypted?** YES
- ✅ **Is data transmitted securely?** YES (HTTPS)
- ✅ **Can users request deletion?** YES

### Question 4: Data Collection Practices
- ✅ **Is collection optional?** NO (for required data like phone number)
- ✅ **Can users choose not to provide?** NO (phone and order code required for login)

---

## ⚠️ Important Notes

1. **Be accurate:** Make sure your answers match your actual app behavior
2. **Match privacy policy:** Data Safety form must match your privacy policy
3. **If unsure:** Review your code and privacy policy before submitting
4. **Update if changes:** If you add new data collection, update the form

---

## 🔗 Related Documents

- **Privacy Policy:** See `PRIVACY_POLICY.html`
- **Publishing Guide:** See `GOOGLE_PLAY_PUBLISHING_GUIDE.md`

---

## Quick Summary

**What actually happens in your app:**
1. User enters phone + order code → Login
2. Server returns client data (name, phone, etc.) → App stores locally
3. App stores JWT token → For session management
4. Android system provides device info → Automatically (not collected by your code)
5. NO analytics or tracking → App does NOT monitor user behavior

**Data types to declare:**
1. ✅ Personal Info (Name, Phone - received from server, stored locally)
2. ✅ Authentication Info (Order code entered, JWT token received)
3. ❌ App Activity (NOT collected - skip this)
4. ✅ Device IDs (System provides automatically)
5. ✅ Financial Info (Only if WooCommerce purchases enabled)

**All data:**
- ✅ Encrypted in transit (HTTPS) and at rest (Secure Storage)
- ✅ Not shared with third parties (except WooCommerce for orders if enabled)
- ✅ Required for app functionality (can't work without it)
- ✅ Users can request deletion (logout or delete app)

## 💡 Key Point

**Your app doesn't "collect" data in the traditional sense** - it:
- Uses data user provides (login credentials)
- Receives data from your server (client info already in your system)
- Stores data locally (for session management)
- Accesses system data (device info - automatic)

Google Play considers all of this as "data collection" even if you're not actively tracking or monitoring users.

