# 1. Python Import Mental Model

Python:

```python
from math import floor

print(floor(4.7))
```

or

```python
import math

print(math.floor(4.7))
```

Python imports:

```text
Module
Package
Function
Class
Variable
```

---

# 2. Dart Import Mental Model

Dart imports **files (libraries)**.

Example:

```dart
import 'package:flutter/material.dart';
```

This imports the entire library.

Then you can use:

```dart
Text()
Scaffold()
Column()
Row()
```

without importing them individually.

Think:

```python
from flutter.material import *
```

(Not exactly, but close enough mentally.)

---

# Example

Suppose you create:

```text
lib/
 ├── models/
 │    └── user.dart
```

user.dart

```dart
class User {
  String name;

  User(this.name);
}
```

Now import:

```dart
import '../models/user.dart';
```

Then:

```dart
User user = User("Jay");
```

You don't write:

```dart
user.User(...)
```

like Python.

The class becomes directly available.

---

# 3. Importing Files From Your Project

Example:

```text
lib/
 ├── screens/
 │    └── home_screen.dart
 │
 └── widgets/
      └── lesson_card.dart
```

home_screen.dart:

```dart
import '../widgets/lesson_card.dart';
```

Now Flutter knows:

```dart
LessonCard(...)
```

exists.

---

# Similar Python Example

Python:

```python
from widgets.lesson_card import LessonCard

card = LessonCard()
```

Dart:

```dart
import '../widgets/lesson_card.dart';

LessonCard(...)
```

Very similar.

---

# 4. Why No `from X import Y`?

Dart imports the library.

Example:

```dart
import '../models/user.dart';
```

If that file contains:

```dart
class User {}
class Account {}
class Customer {}
```

All become available:

```dart
User()
Account()
Customer()
```

---

# 5. Alias Imports

Python:

```python
import pandas as pd
```

Dart:

```dart
import 'package:http/http.dart' as http;
```

Use:

```dart
http.get(...)
```

Example:

```dart
final response =
    await http.get(
      Uri.parse("https://google.com"),
    );
```

Exactly like:

```python
import requests as req

req.get(...)
```

---

# 6. How Dependencies Work

When you install:

```bash
flutter pub add http
```

Flutter updates:

```yaml
dependencies:
  http: ^1.5.0
```

Now Dart knows:

```dart
import 'package:http/http.dart';
```

means:

```text
Find package "http"
Load http.dart
```

---

# Import Types

## Type 1: Dart SDK

```dart
import 'dart:convert';
```

Provides:

```dart
jsonEncode()
jsonDecode()
```

Like:

```python
import json
```

---

## Type 2: Flutter SDK

```dart
import 'package:flutter/material.dart';
```

Provides:

```dart
Scaffold
Text
Column
Row
Icon
```

Like:

```python
from tkinter import *
```

---

## Type 3: External Package

```dart
import 'package:http/http.dart' as http;
```

Installed via:

```bash
flutter pub add http
```

Like:

```python
import requests
```

---

## Type 4: Local Project File

```dart
import '../models/user.dart';
```

Like:

```python
from models.user import User
```

---

# Variables

Exactly like other languages.

```dart
String name = "Jay";

int age = 30;

bool active = true;
```

Use:

```dart
print(name);
```

---

# Functions

```dart
String greet(String name) {
  return "Hello $name";
}
```

Call:

```dart
print(greet("Jay"));
```

---

# Classes

```dart
class User {
  String name;

  User(this.name);
}
```

Create object:

```dart
User user = User("Jay");
```

Access:

```dart
print(user.name);
```

Python equivalent:

```python
class User:
    def __init__(self, name):
        self.name = name

user = User("Jay")
print(user.name)
```

---

# Static Methods

Python:

```python
class Math:
    @staticmethod
    def add(a,b):
        return a+b

Math.add(1,2)
```

Dart:

```dart
class MathUtils {
  static int add(int a, int b) {
    return a + b;
  }
}
```

Call:

```dart
MathUtils.add(1,2);
```

---

# Widgets Are Classes

This is the big Flutter realization.

When you write:

```dart
Text("Hello")
```

you're actually creating an object.

Internally:

```dart
Text text = Text("Hello");
```

Similarly:

```dart
Container(...)
```

is:

```dart
Container container = Container(...);
```

---

# This Code

```dart
body: WidgetsScreen(),
```

works because:

```dart
import 'widgets_screen.dart';
```

made the class available.

Flutter sees:

```dart
class WidgetsScreen extends StatelessWidget
```

and creates an object:

```dart
WidgetsScreen()
```

just like:

```dart
User()
```

---

# Real Mental Model

When you see:

```dart
body: WidgetsScreen(),
```

Think:

```text
Create object of WidgetsScreen class
        ↓
Flutter calls build()
        ↓
Returns widget tree
        ↓
Rendered on screen
```

So Flutter is mostly:

```text
Classes
Objects
Functions
Imports
```

The only special thing is that many of those classes happen to represent UI widgets.

---

# Import Cheat Sheet

```dart
// Dart SDK
import 'dart:convert';

// Flutter SDK
import 'package:flutter/material.dart';

// External Package
import 'package:http/http.dart' as http;

// Your Project File
import '../models/user.dart';
```

And when you see:

```dart
WidgetsScreen()
ApiService.fetchUsers()
User.fromJson()
```

just think:

> "I'm calling a class constructor or method from a file that was imported earlier."


Excellent question. This gets into how Dart compilation and imports actually work.

Short answer:

> **No, Flutter does not silently ignore bad imports.**
>
> If the file doesn't exist, the app won't compile and you'll get an error immediately.

---

# Example

Suppose you have:

```text
lib/
├── screens/
│   └── home_screen.dart
│
└── widgets/
    └── lesson_card.dart
```

Inside:

```dart
// home_screen.dart

import '../widgets/lesson_card.dart';
```

Flutter resolves:

```text
Current file:
lib/screens/home_screen.dart

Go up one folder:
lib/

Then:
widgets/lesson_card.dart
```

Result:

```text
lib/widgets/lesson_card.dart
```

---

# What if file doesn't exist?

Suppose:

```dart
import '../widgets/does_not_exist.dart';
```

Run:

```bash
flutter run -d chrome
```

Error:

```text
Target of URI doesn't exist:
'../widgets/does_not_exist.dart'
```

Compilation fails.

Nothing runs.

---

# When is import checked?

Before the app starts.

Roughly:

```text
flutter run
    ↓
Dart compiler
    ↓
Resolve imports
    ↓
Build dependency graph
    ↓
Compile
    ↓
Launch app
```

If any import is broken:

```text
Compilation stops
```

---

# Similar to Python

Python:

```python
from math2 import floor
```

Error:

```text
ModuleNotFoundError
```

But notice:

Python errors happen at runtime.

---

Flutter/Dart:

```dart
import 'math2.dart';
```

Usually caught before app starts.

More like:

```text
Compile-time validation
```

---

# How Flutter Finds Files

Suppose:

```text
lib/
├── screens/
│   └── home_screen.dart
│
└── widgets/
    └── lesson_card.dart
```

Inside:

```dart
import '../widgets/lesson_card.dart';
```

Meaning:

```text
..
```

=

```text
Go to parent directory
```

Like Linux:

```bash
cd ..
```

---

# Multiple Levels

Example:

```dart
import '../../models/user.dart';
```

Meaning:

```text
Current Folder
   ↑
Parent
   ↑
Parent
   ↓
models/user.dart
```

---

# Why Relative Imports Can Become Annoying

Imagine:

```text
lib/
├── features/
│   ├── users/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── payments/
│
└── shared/
```

Then imports look like:

```dart
import '../../../shared/utils.dart';
```

This becomes hard to maintain.

---

# Preferred Flutter Style

Most real Flutter projects use package imports.

Instead of:

```dart
import '../widgets/lesson_card.dart';
```

Use:

```dart
import 'package:flutter_learning/widgets/lesson_card.dart';
```

where:

```yaml
name: flutter_learning
```

comes from:

```yaml
pubspec.yaml
```

---

# Example

pubspec.yaml:

```yaml
name: flutter_learning
```

Now anywhere:

```dart
import 'package:flutter_learning/widgets/lesson_card.dart';
```

Benefits:

✅ Works from any folder

✅ Easier refactoring

✅ No counting `../`

✅ Used in professional projects

---

# How Dart Knows What To Compile

Suppose:

```text
main.dart
    ↓
home_screen.dart
    ↓
lesson_card.dart
```

Flutter builds an import graph:

```text
main.dart
    |
    +---- home_screen.dart
                |
                +---- lesson_card.dart
```

Only imported files become part of the application.

Unused files are ignored.

---

# Example

Project:

```text
lib/
├── main.dart
├── user.dart
├── payment.dart
└── random.dart
```

main.dart:

```dart
import 'user.dart';
```

Only:

```text
main.dart
user.dart
```

are pulled into the dependency graph.

If:

```text
random.dart
```

is never imported:

```text
Compiler ignores it.
```

---

# What Happens During Hot Reload?

Suppose:

```dart
import '../widgets/lesson_card.dart';
```

exists.

Then you rename:

```text
lesson_card.dart
```

to

```text
card.dart
```

without updating import.

Save.

Flutter immediately shows:

```text
Target of URI doesn't exist
```

Hot reload fails.

App doesn't rebuild.

---

# Professional Flutter Recommendation

As you start learning, use:

```dart
import '../widgets/lesson_card.dart';
```

because it's easy to understand.

Once comfortable, switch to:

```dart
import 'package:flutter_learning/widgets/lesson_card.dart';
```

This is what you'll see in most production Flutter codebases.

Think of it like:

```python
from myapp.widgets.lesson_card import LessonCard
```

instead of playing with relative paths everywhere.
