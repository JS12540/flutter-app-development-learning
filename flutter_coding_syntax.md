```text
Dart = Programming Language
Flutter = Framework / SDK / Ecosystem
```

Think of it like:

| Language   | Framework   |
| ---------- | ----------- |
| JavaScript | React       |
| TypeScript | Angular     |
| Python     | Django      |
| Kotlin     | Android SDK |
| Dart       | Flutter     |

---

# Dart

Dart is the programming language.

It provides:

```dart
variables
functions
classes
objects
inheritance
interfaces
async/await
collections
generics
```

Example:

```dart
class User {
  String name;

  User(this.name);
}

void main() {
  User user = User("Jay");
  print(user.name);
}
```

This is pure Dart.

No Flutter involved.

You can run it with:

```bash
dart run
```

---

# Flutter

Flutter is Google's UI framework built using Dart.

Flutter provides:

```text
Widgets
Buttons
TextFields
Navigation
Animations
Themes
State Management
Rendering Engine
Android/iOS Integration
```

Example:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Hello"),
        ),
      ),
    ),
  );
}
```

This is Flutter.

---

# Relationship

```text
           Flutter
        /    |     \
       /     |      \
   Widgets  UI   Mobile SDK
       \     |      /
        \    |     /
            Dart
```

Flutter itself is written largely in Dart, and all Flutter apps are written in Dart.

---

# Another way to think about it

Suppose you're building a banking app.

### Dart handles

```text
Classes
Models
API calls
Business logic
Calculations
Data manipulation
```

Example:

```dart
class Account {
  double balance;

  Account(this.balance);

  void deposit(double amount) {
    balance += amount;
  }
}
```

### Flutter handles

```text
Screens
Buttons
Forms
Lists
Navigation
Animations
```

Example:

```dart
ElevatedButton(
  onPressed: depositMoney,
  child: Text("Deposit"),
)
```

---

# What actually gets compiled?

Your Flutter code:

```text
lib/
```

contains Dart files.

Flutter then compiles Dart into native code.

For Android:

```text
Dart
 ↓
Flutter Engine
 ↓
ARM Native Code
 ↓
APK
```

For iPhone:

```text
Dart
 ↓
Flutter Engine
 ↓
iOS Native Code
 ↓
IPA
```

---

# What should you learn first?

Since you're coming from a software engineering background, I'd recommend:

### Phase 1 — Pure Dart (1 week)

Learn:

* Variables
* Functions
* Classes
* OOP
* Lists
* Maps
* Null Safety
* Async/Await
* Futures
* JSON Parsing
* HTTP Calls

Run everything using:

```bash
dart run bin/learn.dart
```

No Flutter.

---

### Phase 2 — Flutter Basics

Learn:

* Widget
* Build method
* StatelessWidget
* StatefulWidget
* Scaffold
* Column
* Row
* Container
* ListView

---

### Phase 3 — Real Android App

Build:

```text
Login Screen
↓
Dashboard
↓
API Call
↓
List Data
↓
Details Screen
```

This is where Flutter starts feeling like Android development.

So your statement is correct:

> Dart is the language. Flutter is the framework/ecosystem that uses Dart to build Android, iOS, Web, and Desktop applications.


# 1. Create a Dart learning file

Inside your Flutter project, create:

```text
bin/learn.dart
```

So your project becomes:

```text
hello_flutter/
├── lib/
│   └── main.dart
├── bin/
│   └── learn.dart
├── android/
└── pubspec.yaml
```

# 2. Add simple Dart code

```dart
void main() {
  String name = "Jay";
  int age = 25;
  double price = 99.99;
  bool isLearning = true;

  print(name);
  print(age);
  print(price);
  print(isLearning);
}
```

# 3. Run only this Dart file

From the project root:

```bash
dart run bin/learn.dart
```

or:

```bash
flutter pub get
dart run bin/learn.dart
```

This will run only that file.

It will not build Android.

---

# Important Difference

## Dart file

Used for learning syntax, variables, classes, loops, lists, maps, API calls, OOP.

```bash
dart run bin/learn.dart
```

## Flutter app

Used for UI and mobile app screens.

```bash
flutter run
```

---

# Dart Concepts To Learn First

Learn in this order:

## 1. Variables and data types

```dart
String name = "Jay";
int age = 25;
double amount = 10.5;
bool active = true;

var city = "London";
final country = "UK";
const pi = 3.14;
```

## 2. Lists / arrays

Dart calls arrays **List**.

```dart
List<String> names = ["Jay", "Amit", "Sara"];

print(names[0]);
names.add("John");
```

## 3. Maps / dictionary / object-like data

```dart
Map<String, dynamic> user = {
  "name": "Jay",
  "age": 25,
  "active": true,
};

print(user["name"]);
```

## 4. Conditions

```dart
if (age >= 18) {
  print("Adult");
} else {
  print("Minor");
}
```

## 5. Loops

```dart
for (int i = 0; i < 5; i++) {
  print(i);
}

for (String name in names) {
  print(name);
}
```

## 6. Functions

```dart
int add(int a, int b) {
  return a + b;
}

void sayHello(String name) {
  print("Hello $name");
}
```

## 7. Classes and objects

```dart
class User {
  String name;
  int age;

  User(this.name, this.age);

  void sayHi() {
    print("Hi, I am $name");
  }
}

void main() {
  User user = User("Jay", 25);
  user.sayHi();
}
```

## 8. Null safety

```dart
String? name;

name = "Jay";

print(name);
```

`String?` means the value can be null.

## 9. Async / await

Needed for API calls.

```dart
Future<void> fetchData() async {
  print("Loading...");
  await Future.delayed(Duration(seconds: 2));
  print("Done");
}
```

## 10. API calls

Later you will use packages like:

```yaml
dependencies:
  http: ^1.2.0
```

Example:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> getUsers() async {
  final response = await http.get(
    Uri.parse("https://jsonplaceholder.typicode.com/users"),
  );

  final data = jsonDecode(response.body);
  print(data);
}

void main() {
  getUsers();
}
```

---

# Flutter Concepts To Learn After Dart

After Dart basics, learn Flutter in this order:

## 1. Widgets

Everything in Flutter UI is a widget.

```dart
Text("Hello")
Container()
Column()
Row()
```

## 2. StatelessWidget

For UI that does not change.

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Home");
  }
}
```

## 3. StatefulWidget

For UI that changes.

```dart
setState(() {
  count++;
});
```

## 4. Layout

Learn:

```text
Scaffold
AppBar
Column
Row
Container
Padding
Center
Expanded
ListView
```

## 5. Navigation

Move from one screen to another.

```dart
Navigator.push(...)
```

## 6. Forms

Learn:

```text
TextField
TextFormField
Form
validation
```

## 7. API integration

Fetch data and show it in UI.

## 8. State management

Start simple:

```text
setState
```

Then learn:

```text
Provider
Riverpod
Bloc
```

## 9. Local storage

Learn:

```text
shared_preferences
sqflite
hive
```

## 10. Android release

Learn:

```bash
flutter build apk
flutter build appbundle
```

---

# Best Learning Path

```text
Step 1: Dart syntax
Step 2: Dart functions
Step 3: Dart classes and objects
Step 4: Lists and Maps
Step 5: Async / await
Step 6: API calls in Dart console file
Step 7: Flutter widgets
Step 8: Flutter layouts
Step 9: Flutter screens
Step 10: API calls inside Flutter UI
Step 11: State management
Step 12: Android build and release
```

For now, start with:

```text
bin/learn.dart
```

and run:

```bash
dart run bin/learn.dart
```
