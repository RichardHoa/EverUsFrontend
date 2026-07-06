# EverUs Flutter Code Structure & Documentation Guidelines

This document serves as a guideline for all future refactoring and feature additions in the EverUs Flutter application. It defines the MVC (Model-Controller-View) separation and coding styles, and details the standard format for inline code documentation using Dart triple-slash (`///`) comments.

---

## 1. Directory Structure Convention

When refactoring a complex screen, reorganize the files under a feature-specific directory. For example, for a screen named `FeatureName`:

```
lib/
  screens/
    feature_name/
      feature_name_screen.dart       # The main entry/view wrapper
      feature_name_controller.dart   # ChangeNotifier/State controller
      widgets/                       # Feature-specific sub-widgets
        feature_name_child_a.dart
        feature_name_child_b.dart
```

---

## 2. Separation of Concerns (MVC)

### The Model
- Models should represent plain data structures.
- They should have simple JSON serialization support (`fromJson`, `toJson`).
- Place global models under `lib/models/`.

### The Controller
- The controller extends `ChangeNotifier`.
- It holds all state variables (e.g., inputs, loaders, active data).
- It handles asynchronous tasks (e.g., HTTP/API requests, local cache reads).
- It notifies listeners (`notifyListeners()`) when state changes, so the UI can rebuild.
- **Never** perform business logic directly inside views or UI callbacks.

### The View (Widgets)
- Decompose complex pages into small, focused stateless or stateful widgets.
- Widgets receive the controller instance (or values from it) and render accordingly.
- UI elements shouldn't mutate state directly; they call methods on the controller.

---

## 3. Inline Documentation Template (Dart `///`)

Every class, constructor, property, and method must be documented using triple-slash (`///`) doc comments. Ensure comments describe the **Why** and explain parameters, returns, and examples.

### Class Example
```dart
/// Represents the controller that manages state and operations for the Date Planner.
///
/// It extends [ChangeNotifier] to alert the view layer when state changes occur.
class DatePlannerController extends ChangeNotifier {
  ...
}
```

### Property Example
```dart
  /// The currently selected date of the planned meeting.
  ///
  /// Defaults to [DateTime.now()].
  DateTime selectedDate = DateTime.now();
```

### Function Example
```dart
  /// Generates a new date plan based on the inputs stored in this controller.
  ///
  /// Throws an [Exception] if the destination area is empty.
  /// Uses [DatePlannerGenerator.generate] to contact the backend service.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.generatePlan();
  ///   print("Plan generated successfully: ${controller.generatedPlan?.id}");
  /// } catch (e) {
  ///   print("Failed: $e");
  /// }
  /// ```
  Future<void> generatePlan() async {
    ...
  }
```

---

## 4. Trace: Next Refactoring Targets

The next AI or developer working on improving the cleanliness of the codebase should target these files using the same structure:

1. **Love Counter Screen** (`lib/screens/love_counter_screen.dart`):
   - **Issues**: Contains animations, image picker logic, countdown timers, preference syncing, and local database storage.
   - **Refactoring Strategy**: Create a `LoveCounterController` to manage the countdown clock, selected backgrounds, local caching, and custom preferences. Move custom widgets like `HeartMascot` or custom cards to its local widgets folder.

2. **Login Screen** (`lib/screens/login_screen.dart`):
   - **Issues**: Mixed UI authentication state, layout styles, and Apple/Google sign-in handlers.
   - **Refactoring Strategy**: Move sign-in state, loaders, and credential handlers into a separate controller class or use a unified `AuthController`.

3. **Notifications Screen** (`lib/screens/notifications_screen.dart`):
   - **Issues**: Inline notification list management and read state modifications.
   - **Refactoring Strategy**: Create a helper controller to observe new notification events and update server metrics.
