This is where Flutter differs from normal Dart.

For **Phase 1 (Dart)**:

```bash
dart run bin/learn.dart
```

No UI.
No emulator.
No APK.

---

For **Phase 2 (Flutter Widgets)**:

You need Flutter's rendering engine because widgets are UI objects.

A widget like:

```dart
Text("Hello")
```

cannot be executed with:

```bash
dart run
```

because it's not a normal Dart program.

Flutter must render it.

---

# Fastest way to learn Flutter UI

You do **NOT** need to build an APK every time.

Use:

```bash
flutter run
```

Flutter will:

1. Compile once
2. Launch app
3. Enable Hot Reload

After that:

```text
Save file
↓
Press r
↓
UI updates instantly
```

No APK rebuild.

---

# Option 1: Use Chrome (Recommended for Learning)

You don't even need Android initially.

Check devices:

```bash
flutter devices
```

Example:

```text
Chrome
Windows
Android Emulator
```

Run:

```bash
flutter run -d chrome
```

Now Flutter opens in Chrome.

You can learn:

```text
Widget
Column
Row
Container
ListView
StatefulWidget
StatelessWidget
```

without Android Studio or APKs.

---

# Option 2: Android Emulator

Start emulator:

```bash
flutter emulators
flutter emulators --launch <id>
```

Then:

```bash
flutter run
```

Hot reload works here too.

---

# Option 3: Flutter Widget Playground App

Create a single screen:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WidgetPlayground(),
    );
  }
}

class WidgetPlayground extends StatelessWidget {
  const WidgetPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Learning"),
      ),
      body: const Center(
        child: Text("Hello Flutter"),
      ),
    );
  }
}
```

Run once:

```bash
flutter run -d chrome
```

Then keep modifying the UI.

---

# Think of Flutter like React

In React:

```jsx
function App() {
  return <div>Hello</div>;
}
```

Need browser to render.

---

In Flutter:

```dart
Widget build(BuildContext context) {
  return Text("Hello");
}
```

Need Flutter engine to render.

---

# Best Learning Workflow

### Create project

```bash
flutter create --platforms=android flutter_learning
```

or

```bash
flutter create flutter_learning
```

---

### Run in browser

```bash
flutter run -d chrome
```

---

### Edit only

```text
lib/main.dart
```

---

### Save

```text
Ctrl + S
```

---

### Hot reload

```text
r
```

or VS Code:

```text
⚡ Hot Reload button
```

---

# Learning order

## Lesson 1

Learn:

```dart
Text()
Center()
```

---

## Lesson 2

Learn:

```dart
Container()
```

---

## Lesson 3

Learn:

```dart
Column()
```

```dart
Column(
  children: [
    Text("A"),
    Text("B"),
  ],
)
```

---

## Lesson 4

Learn:

```dart
Row()
```

```dart
Row(
  children: [
    Text("A"),
    Text("B"),
  ],
)
```

---

## Lesson 5

Learn:

```dart
Scaffold()
```

```dart
Scaffold(
  appBar: AppBar(),
  body: ...
)
```

---

## Lesson 6

Learn:

```dart
StatelessWidget
```

---

## Lesson 7

Learn:

```dart
StatefulWidget
setState()
```

---

## Lesson 8

Learn:

```dart
ListView()
```

---

# Can I run a Flutter widget without compiling?

**Not really.**

A Flutter widget:

```dart
Text("Hello")
```

must be rendered by the Flutter engine.

But the good news is:

```bash
flutter run -d chrome
```

is effectively the Flutter equivalent of:

```bash
python app.py
```

for learning purposes. You start it once, then use Hot Reload and rarely think about compilation while learning widgets.
