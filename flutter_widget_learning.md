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


Since your goal is to **learn Flutter fundamentals systematically**, I'd recommend treating Flutter like a UI framework and building a small "playground" app that you keep modifying.

---

# Phase 0: Setup Once

## Verify Flutter

```bash
flutter doctor
```

Make sure Chrome is detected.

You should see something like:

```text
[✓] Chrome
```

---

## Create Learning Project

```bash
flutter create flutter_learning
```

Enter project:

```bash
cd flutter_learning
```

---

## See Available Devices

```bash
flutter devices
```

Expected:

```text
Chrome
Windows
...
```

---

## Run In Chrome

```bash
flutter run -d chrome
```

Chrome opens.

Leave this terminal running.

---

# Daily Learning Workflow

Open:

```text
lib/main.dart
```

Modify code.

Save:

```text
Ctrl + S
```

Flutter automatically hot reloads.

Or press:

```text
r
```

in terminal.

---

# Phase 1: Understand Widget Tree

Everything in Flutter is a Widget.

Replace `main.dart` with:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Text('Hello Flutter'),
    ),
  );
}
```

Learn:

```text
runApp()
MaterialApp()
Text()
```

Understand:

```text
Widget
  └── Widget
       └── Widget
```

Flutter UI is just a tree of widgets.

---

# Phase 2: Learn Scaffold

Replace with:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello Flutter'),
        ),
      ),
    ),
  );
}
```

Learn:

```text
Scaffold
Center
Text
```

Think:

```text
Scaffold = Page
```

Like an Android Activity screen.

---

# Phase 3: Learn Container

Try:

```dart
Container(
  width: 200,
  height: 100,
  child: Text('Container'),
)
```

Then add:

```dart
color: Colors.blue,
padding: EdgeInsets.all(20),
```

Learn:

```text
width
height
padding
margin
color
alignment
```

Container is similar to:

```text
HTML div
```

---

# Phase 4: Learn Column

```dart
Column(
  children: [
    Text('One'),
    Text('Two'),
    Text('Three'),
  ],
)
```

Result:

```text
One
Two
Three
```

Learn:

```text
children
mainAxisAlignment
crossAxisAlignment
```

Column = Vertical Layout

---

# Phase 5: Learn Row

```dart
Row(
  children: [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
```

Result:

```text
A B C
```

Row = Horizontal Layout

---

# Phase 6: Learn Container + Row + Column Together

Build:

```text
Profile Card

[Avatar]
John Doe
Developer
```

Example:

```dart
Container(
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      Icon(Icons.person),
      Text('John Doe'),
      Text('Developer'),
    ],
  ),
)
```

This is where layouts start making sense.

---

# Phase 7: Learn StatelessWidget

Create:

```dart
class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("User Card");
  }
}
```

Use:

```dart
body: UserCard(),
```

Learn:

```text
Widget reuse
Composition
build()
```

---

# Phase 8: Understand Build Method

```dart
Widget build(BuildContext context)
```

Think:

> "How should this widget look right now?"

Flutter calls build many times.

Example:

```dart
@override
Widget build(BuildContext context) {
  print("Building");

  return Text("Hello");
}
```

You'll see it run repeatedly.

---

# Phase 9: Learn StatefulWidget

Counter example:

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() {
    return _CounterPageState();
  }
}

class _CounterPageState extends State<CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$count'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            count++;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

Learn:

```text
State
setState()
Rebuild
```

This is one of the most important Flutter concepts.

---

# Phase 10: Learn ListView

```dart
ListView(
  children: [
    Text('Item 1'),
    Text('Item 2'),
    Text('Item 3'),
  ],
)
```

Then:

```dart
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item $index'),
    );
  },
)
```

Learn:

```text
Scrolling
Dynamic Lists
Builders
```

---

# Final Goal

After these lessons you should be able to build:

```text
Scaffold
│
├── AppBar
│
└── ListView
     │
     ├── UserCard
     ├── UserCard
     └── UserCard
```

Which is already enough knowledge to build:

* Todo App
* Notes App
* Contact List
* API Data Viewer
* Dashboard Screen

---

## Commands You'll Actually Use Every Day

Start app:

```bash
flutter run -d chrome
```

Hot reload:

```text
Ctrl + S
```

or

```text
r
```

Hot restart:

```text
R
```

Stop app:

```text
Ctrl + C
```

That's it. For the first week, you can ignore APKs, Android emulators, Gradle, and the `android/` folder entirely and learn Flutter UI entirely in Chrome.
