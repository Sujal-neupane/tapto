# New Components Reference Guide

## Component Imports

Add these to any screen where you want to use the new components:

```dart
// For CustomAppBar (unified header across all screens)
import '../../../../app/widgets/custom_app_bar.dart';

// For LogoutDialog (professional logout confirmation)
import '../../../../app/widgets/logout_dialog.dart';

// For TimerWidget (active session timer)
import '../../../../app/widgets/timer_widget.dart';

// For TimeTrackingCard (session history card)
import '../../../../app/widgets/time_tracking_card.dart';
```

---

## CustomAppBar Usage

### Basic Usage
```dart
Scaffold(
  appBar: CustomAppBar(
    title: 'Screen Title',
  ),
  body: ...,
)
```

### With Subtitle
```dart
appBar: CustomAppBar(
  title: 'My Profile',
  subtitle: 'user@example.com',
)
```

### With Back Button
```dart
appBar: CustomAppBar(
  title: 'Product Details',
  showBackButton: true,
)
```

### With Actions
```dart
appBar: CustomAppBar(
  title: 'Dashboard',
  showBackButton: false,
  actions: [
    IconButton(
      icon: const Icon(Icons.favorite_border),
      onPressed: () {},
    ),
  ],
)
```

### Parameters
- `title` (String, required): Main header text
- `subtitle` (String, optional): Secondary text below title
- `actions` (List<Widget>, optional): Right-side action buttons
- `onBackPressed` (VoidCallback, optional): Custom back action
- `showBackButton` (bool, default: false): Show/hide back button
- `showLogo` (bool, default: true): Show/hide app logo

---

## LogoutDialog Usage

### Simple Logout Dialog
```dart
showDialog(
  context: context,
  builder: (context) => const LogoutDialog(
    onConfirm: () {
      // Your logout logic here
      Navigator.pop(context);
    },
  ),
)
```

### With Custom Callback
```dart
LogoutDialog(
  onConfirm: () async {
    await authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login');
  },
)
```

### Parameters
- `onConfirm` (VoidCallback, optional): Called when user clicks Logout

---

## TimerWidget Usage

### Active Timer
```dart
TimerWidget(
  isRunning: true,
  onStop: () {
    print('Session stopped');
  },
)
```

### Inactive Timer (for past sessions)
```dart
const TimerWidget(
  isRunning: false,
)
```

### Parameters
- `isRunning` (bool, default: true): Start timer automatically
- `onStop` (VoidCallback, optional): Callback when stop button pressed

### Features
- Auto-formatting: HH:MM:SS display
- Real-time updates every second
- Active status badge
- Professional red stop button
- Gradient background with primary color accent

---

## TimeTrackingCard Usage

### Basic Session Display
```dart
TimeTrackingCard(
  sessionName: 'Shopping Session',
  duration: const Duration(hours: 1, minutes: 30),
  category: 'Shopping',
  startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
)
```

### In a List
```dart
ListView(
  children: [
    TimeTrackingCard(
      sessionName: 'Morning Shopping',
      duration: const Duration(minutes: 45),
      category: 'Fashion',
      startTime: DateTime(2024, 1, 15, 9, 0),
    ),
    TimeTrackingCard(
      sessionName: 'Afternoon Browse',
      duration: const Duration(hours: 2),
      category: 'Electronics',
      startTime: DateTime(2024, 1, 15, 14, 0),
    ),
  ],
)
```

### Parameters
- `sessionName` (String, required): Name of the session
- `duration` (Duration, required): Total session duration
- `category` (String, required): Category/type of session
- `startTime` (DateTime, required): When session started

### Display Features
- Automatic duration formatting
- Category badge with primary color
- Timer icon container with gradient
- Total time display in large format
- Subtle shadows and borders

---

## Color System Usage

All screens should use `AppColors` constants:

```dart
import '../../../../app/theme/app_colors.dart';

// Examples
Container(
  color: AppColors.surface,  // Light gray background
)

Text(
  'Primary Text',
  style: TextStyle(color: AppColors.textPrimary),  // Dark gray
)

IconButton(
  icon: const Icon(Icons.favorite, color: AppColors.primary),  // Blue
)

Text(
  'Secondary Text',
  style: TextStyle(color: AppColors.textSecondary),  // Medium gray
)

Container(
  border: Border.all(color: AppColors.border),  // Light border
)

Text(
  'Error Message',
  style: TextStyle(color: AppColors.error),  // Red
)

Text(
  'Success Message',
  style: TextStyle(color: AppColors.success),  // Green
)
```

---

## Spacing System Usage

Always use `AppSpacing` constants:

```dart
import '../../../../app/theme/app_spacing.dart';

// Examples
const SizedBox(height: AppSpacing.xs),    // 4px
const SizedBox(height: AppSpacing.sm),    // 8px
const SizedBox(height: AppSpacing.md),    // 16px
const SizedBox(height: AppSpacing.lg),    // 24px
const SizedBox(height: AppSpacing.xl),    // 32px

// In padding
padding: const EdgeInsets.all(AppSpacing.lg),
padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
```

---

## Modern Container Pattern

Use this pattern for consistent modern containers:

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.border,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: // Your content here
)
```

---

## Modern Button Pattern

Use this pattern for consistent modern buttons:

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: const Text('Button Text'),
)
```

---

## Files Structure

```
lib/
├── app/
│   ├── widgets/
│   │   ├── custom_app_bar.dart        (NEW - Reusable AppBar)
│   │   ├── logout_dialog.dart         (NEW - Logout dialog)
│   │   ├── timer_widget.dart          (NEW - Active timer)
│   │   └── time_tracking_card.dart    (NEW - Session card)
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       └── app_text_styles.dart
└── features/
    └── dashboard/
        └── presentation/
            └── pages/
                ├── dashboard_screen.dart      (UPDATED)
                ├── profile_screen.dart        (UPDATED)
                ├── home_swipe_screen.dart     (UPDATED with timer)
                ├── product_details_screen.dart (UPDATED)
                ├── cart_screen.dart           (UPDATED)
                ├── search_screen.dart         (UPDATED)
                ├── filter_screen.dart         (UPDATED)
                └── wish_list_screen.dart      (UPDATED)
```

---

## Next Steps for Enhancement

1. **Session Persistence**
   - Save sessions to Hive
   - Load past sessions on app startup

2. **Statistics Dashboard**
   - Show time spent by category
   - Daily/weekly/monthly analytics

3. **Session Categories**
   - Allow users to categorize sessions
   - Customize category colors

4. **Notifications**
   - Alert after reaching time milestones
   - Session reminders

5. **Data Export**
   - Export time tracking data
   - CSV/PDF reports

6. **Advanced Analytics**
   - Charts and graphs of time data
   - Productivity insights

---

## Troubleshooting

### TimerWidget not starting?
```dart
// Make sure isRunning is true
const TimerWidget(isRunning: true)  // ✓ Correct

// NOT this
const TimerWidget(isRunning: false) // ✗ Won't start
```

### CustomAppBar back button not working?
```dart
// Make sure showBackButton is true
CustomAppBar(
  title: 'Title',
  showBackButton: true,  // ✓ Required
)
```

### Colors not applying?
```dart
// Import is required
import '../../../../app/theme/app_colors.dart';

// Then use
color: AppColors.primary  // ✓ Correct
```

### Spacing looks wrong?
```dart
// Use constants, not magic numbers
height: AppSpacing.md     // ✓ Correct (16px)
height: 16               // ✗ Hardcoded
```
