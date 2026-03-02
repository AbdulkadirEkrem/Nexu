# nexu_planner - Project Feature Summary

## Overview
nexu_planner is a Flutter-based team scheduling and meeting management application with real-time collaboration features. The app enables users to manage their calendars, view colleague availability, send meeting requests, and receive push notifications.

---

## Technical Architecture

### **State Management**
- **Provider Pattern**: Uses `provider` package for state management
- **Providers**:
  - `UserProvider`: Manages authentication state and current user data
  - `CalendarProvider`: Handles calendar events and real-time updates
  - `RequestProvider`: Manages meeting requests (incoming/outgoing)
  - `TeamProvider`: Manages team/colleague list

### **Navigation**
- **GoRouter**: Declarative routing with authentication guards
- **Routes**:
  - `/login` - Authentication screen
  - `/home` - Main calendar screen
  - `/team` - Team/colleagues list
  - `/user-detail` - Individual user profile and availability
  - `/profile` - Current user profile
  - `/notifications` - Meeting requests inbox

---

## Core Modules

### 1. **Authentication Module** (`lib/services/firebase_auth_service.dart`)
**Status**: ✅ Complete

**Features**:
- Email/password authentication via Firebase Auth
- User registration (sign up)
- User login (sign in)
- Auto-login on app restart (listens to `authStateChanges`)
- Domain validation (enforces company email domains)
- Session persistence

**Integration**:
- `UserProvider` wraps `FirebaseAuthService`
- `LoginScreen` handles UI for login/signup
- User data automatically saved to Firestore on signup

---

### 2. **Firestore Database Module** (`lib/services/firestore_service.dart`)
**Status**: ✅ Complete

**Collections**:
- **`users`**: User profiles
  - Fields: `id`, `name`, `email`, `department`, `position`, `companyDomain`, `avatarUrl`, `avatarId`, `fcmToken`, `fcmTokenUpdatedAt`
- **`events`**: Calendar events
  - Fields: `id`, `title`, `description`, `startTime`, `endTime`, `userId`, `userName`, `type`, `location`, `createdAt`
- **`requests`**: Meeting requests
  - Fields: `id`, `title`, `date`, `startTime`, `endTime`, `durationMinutes`, `requesterId`, `requesterName`, `recipientId`, `recipientName`, `status`, `createdAt`, `createdAtTimestamp`, `respondedAt`

**Key Methods**:
- **User Management**:
  - `saveUser()`: Save/update user profile
  - `getUser()`: Fetch user by ID
  - `updateUser()`: Update user profile
  - `updateFCMToken()`: Store FCM token for push notifications
  - `getUsersByCompanyDomain()`: Get colleagues by company domain
  - `streamColleagues()`: Real-time stream of colleagues

- **Event Management**:
  - `addEvent()`: Create new calendar event
  - `streamEvents()`: Real-time stream of user's events
  - `streamUserEvents()`: Stream events for viewing other users' calendars
  - `getEventsForDate()`: Get events for specific date
  - `getEventsForDateRange()`: Get events for date range
  - `deleteEvent()`: Remove event

- **Meeting Request Management**:
  - `sendMeetingRequest()`: Create and send meeting request (triggers push notification)
  - `streamIncomingRequests()`: Real-time stream of pending incoming requests
  - `streamAllOutgoingRequests()`: Real-time stream of all outgoing requests (pending/accepted/declined)
  - `streamOutgoingRequests()`: Real-time stream of feedback (accepted/declined only)
  - `respondToRequest()`: Accept/decline request (creates events for both users if accepted)
  - `dismissRequest()`: Delete request document

---

### 3. **Calendar Module** (`lib/providers/calendar_provider.dart`, `lib/screens/home/my_calendar_screen.dart`)
**Status**: ✅ Complete

**Features**:
- **TableCalendar Integration**: Visual calendar with month/week views
- **Event Markers**: Red dots indicate days with events
- **Real-time Updates**: Calendar markers update automatically when events are added/removed
- **Event Management**:
  - Add events via FloatingActionButton
  - View events for selected date
  - Delete events
- **Event Types**: Tasks, Meetings, etc.

**UI Components**:
- Calendar widget with date selection
- Event list for selected day
- Add Event bottom sheet (title, date, time picker)
- Empty state when no events

---

### 4. **Team/Colleagues Module** (`lib/providers/team_provider.dart`, `lib/screens/team/team_list_screen.dart`)
**Status**: ✅ Complete

**Features**:
- **Colleague Discovery**: Automatically filters users by `companyDomain`
- **Real-time Updates**: Streams colleagues list from Firestore
- **User Profiles**: View colleague details (name, email, department, position)
- **Availability Viewing**: See colleague's calendar with privacy (shows "Busy"/"Available" slots)

**UI Components**:
- Team list screen with user cards
- User detail screen with calendar
- Hourly availability slots (9 AM - 5 PM)
- Privacy-aware event display (no event titles shown for others)

---

### 5. **Meeting Request Module** (`lib/providers/request_provider.dart`, `lib/screens/team/user_detail_screen.dart`)
**Status**: ✅ Complete

**Features**:
- **Request Creation**:
  - Select date and time from colleague's availability
  - Set meeting title and duration (30min, 1hr, 1.5hr, 2hr)
  - Conflict detection (warns if colleague is busy)
  - **Past Date Validation**: Prevents selecting past dates/times
- **Request Management**:
  - Send request to colleague
  - Accept/decline incoming requests
  - View sent requests with status (Pending/Accepted/Declined)
  - Dismiss feedback notifications

**UI Components**:
- Meeting request form (bottom sheet)
- Date/time pickers
- Duration dropdown
- Conflict warning display
- Request cards with accept/decline buttons

---

### 6. **Notifications Module** (`lib/screens/notifications/notifications_screen.dart`)
**Status**: ✅ Complete

**Features**:
- **Three Tabs**:
  1. **Incoming**: Pending requests from others (auto-removed when accepted/declined)
  2. **Sent Requests**: All outgoing requests with status badges (Pending/Accepted/Declined)
  3. **Feedback**: Accepted/declined responses to sent requests
- **Real-time Updates**: Lists update automatically via Firestore streams
- **Badge Indicator**: Notification bell shows unread count on home screen
- **Status Indicators**: Color-coded status badges (Orange=Pending, Green=Accepted, Red=Declined)

**UI Components**:
- Tab bar navigation
- Request cards with details
- Accept/Decline buttons
- Status badges
- Empty states

---

### 7. **Push Notifications Module** (`lib/services/fcm_sender_service.dart`, `lib/services/notification_service.dart`)
**Status**: ✅ Complete

**Features**:
- **FCM HTTP v1 API**: Uses latest Firebase Cloud Messaging API
- **Service Account Authentication**: Direct authentication using service account credentials
- **Peer-to-Peer Notifications**: Send notifications when meeting requests are created
- **Background Notifications**: Handles notifications when app is in background
- **Local Notifications**: Displays notifications via `flutter_local_notifications`

**Configuration**:
- Service account credentials stored in `lib/core/secrets/app_secrets.dart`
- Requires: `projectId`, `clientEmail`, `privateKey`
- FCM token stored in user document in Firestore

**Integration**:
- Automatically sends notification when `sendMeetingRequest()` is called
- Notification title: "New Meeting Request"
- Notification body: "You have a new request from {requesterName}."

---

### 8. **User Profile Module** (`lib/screens/profile/profile_screen.dart`, `lib/screens/profile/edit_profile_screen.dart`)
**Status**: ✅ Complete

**Features**:
- View current user profile
- Edit profile (name, department, position)
- Avatar selection
- Profile data synced with Firestore

---

## Data Models

### **UserModel** (`lib/models/user_model.dart`)
- `id`, `email`, `name`, `department`, `position`, `avatarUrl`, `avatarId`, `companyDomain`

### **EventModel** (`lib/models/event_model.dart`)
- `id`, `title`, `description`, `startTime`, `endTime`, `userId`, `userName`, `type`, `location`
- Helper methods: `isOnDate()`, `formattedDate`, `formattedTime`

### **MeetingRequestModel** (`lib/models/meeting_request_model.dart`)
- `id`, `title`, `date`, `startTime`, `duration`, `requesterId`, `requesterName`, `recipientId`, `recipientName`, `status`, `createdAt`
- Status enum: `pending`, `accepted`, `declined`
- Helper methods: `formattedDate`, `formattedTime`, `formattedDuration`

---

## Key Dependencies

### **Core**
- `flutter`: SDK
- `provider`: State management
- `go_router`: Navigation

### **Firebase**
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_messaging`: Push notifications

### **UI/UX**
- `table_calendar`: Calendar widget
- `intl`: Date/time formatting
- `flutter_local_notifications`: Local notifications

### **HTTP/APIs**
- `http`: HTTP requests
- `googleapis_auth`: Google API authentication (for FCM)

---

## Recent Fixes & Improvements

### **UX/Logic Fixes (Latest)**
1. ✅ **Past Date Validation**: Prevents selecting past dates/times for meeting requests
2. ✅ **Sent Requests Tab**: Added dedicated tab showing all outgoing requests with status
3. ✅ **Request Filtering**: Incoming requests automatically removed when accepted/declined
4. ✅ **Reactive Calendar Markers**: Calendar markers update immediately when events are added

---

## Current MVP Status

### ✅ **Completed Features**
- User authentication (sign up/login)
- Calendar management (add/view/delete events)
- Team/colleague discovery
- View colleague availability
- Send meeting requests
- Accept/decline requests
- Push notifications
- Real-time data synchronization
- Profile management

### 🔄 **Potential Future Enhancements**
- Event editing
- Recurring events
- Meeting room booking
- Calendar export (iCal)
- Email notifications
- Meeting reminders
- Conflict resolution suggestions
- Multi-company support
- Admin dashboard

---

## Technical Notes

### **Real-time Updates**
- All data streams use Firestore `snapshots()` for real-time updates
- Providers automatically notify listeners when data changes
- UI components wrapped in `Consumer` widgets for reactive updates

### **Privacy**
- Users can only see colleagues from the same company domain
- Event titles hidden when viewing others' calendars (shows "Busy"/"Available" only)

### **Error Handling**
- Try-catch blocks in all service methods
- Error messages displayed via SnackBars
- Loading states managed in providers

### **Performance**
- Stream subscriptions properly disposed
- Event filtering done client-side to avoid composite index requirements
- Efficient date range queries

---

## File Structure

```
lib/
├── core/
│   ├── constants/      # App colors, text styles
│   ├── secrets/        # App secrets (FCM credentials)
│   └── theme/          # App theme
├── models/             # Data models
├── providers/          # State management providers
├── screens/
│   ├── auth/           # Login screen
│   ├── home/           # Calendar screen
│   ├── notifications/  # Requests inbox
│   ├── profile/        # User profile
│   └── team/           # Team list & user details
├── services/           # Business logic services
└── widgets/            # Reusable UI components
```

---

**Last Updated**: Current MVP implementation complete with all core features functional.

