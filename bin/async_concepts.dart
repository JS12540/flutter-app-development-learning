/*
===============================================================================
DART ASYNC PROGRAMMING MASTER FILE
===============================================================================

This file covers:

1. Futures
2. Async / Await
3. JSON Parsing
4. HTTP Calls
5. Parallel Execution
6. Isolates (Dart's multiprocessing model)
7. Memory Concepts
8. State Concepts

Run:

    dart run bin/async_concepts.dart

===============================================================================
*/

/*
===============================================================================
PACKAGE MANAGEMENT IN DART
===============================================================================

Built-in SDK libraries:

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

These are included with Dart.
No installation required.

-------------------------------------------------------------------------------

External Packages:

Example:

import 'package:http/http.dart' as http;

Must be installed first.

Install using:

    dart pub add http

or in Flutter:

    flutter pub add http

This automatically updates:

    pubspec.yaml

-------------------------------------------------------------------------------

Dart Package Registry:

    https://pub.dev

Equivalent to:

    PyPI (Python)
    NPM (JavaScript)
    Maven (Java)

Search packages at:

    https://pub.dev

Examples:

    http
    dio
    sqflite
    shared_preferences
    flutter_riverpod

-------------------------------------------------------------------------------

Install dependencies:

    dart pub get

or

    flutter pub get

List installed packages:

    dart pub deps

Update packages:

    dart pub upgrade

===============================================================================
*/

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

/*
===============================================================================
SECTION 1 - MEMORY CONCEPTS
===============================================================================

Dart has:

1. Stack Memory
2. Heap Memory

----------------------------------
STACK
----------------------------------

Stores:

- Local variables
- Function calls
- References

Example:

void main() {
  int age = 25;
}

age is stored in stack.

----------------------------------
HEAP
----------------------------------

Stores objects.

Example:

User user = User("Jay");

The object lives in heap.
'user' variable only stores a reference.

----------------------------------
GARBAGE COLLECTION
----------------------------------

Dart automatically removes objects that are no longer referenced.

You do NOT manually free memory.

Unlike C/C++:

    delete user;

is not needed.

===============================================================================
*/

/*
===============================================================================
SECTION 2 - STATE CONCEPTS
===============================================================================

State = data that changes during execution.

Examples:

loading = true
counter = 10
user = fetched API response

Example:

bool isLoading = false;

isLoading = true;

State changed.

In Flutter:

setState() tells UI that state changed.

In pure Dart:

State simply means values currently stored in memory.

===============================================================================
*/

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  /*
  ===========================================================================
  JSON -> OBJECT

  Factory constructor creates an object from JSON.
  ===========================================================================
  */
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  /*
  ===========================================================================
  OBJECT -> JSON
  ===========================================================================
  */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

/*
===============================================================================
SECTION 3 - FUTURES
===============================================================================

Future<T>

Represents a value that will exist later.

Think:

"I don't have the result now.
I promise to give it later."

Examples:

- API calls
- Database calls
- File reads
- Network requests

===============================================================================
*/

Future<String> fetchUserNameFuture() {
  return Future.delayed(
    Duration(seconds: 2),
    () => "Jay",
  );
}

/*
===============================================================================
WITHOUT ASYNC/AWAIT

Old Future style.

===============================================================================
*/

Future<void> futureExample() {
  return fetchUserNameFuture().then((name) {
    print("Future completed");
    print(name);
  });
}

/*
===============================================================================
SECTION 4 - ASYNC / AWAIT
===============================================================================

async
------
Marks function as asynchronous.

await
------
Pause current function until Future completes.

IMPORTANT:

await DOES NOT BLOCK THREAD.

The event loop keeps running.

===============================================================================
*/

Future<void> asyncAwaitExample() async {
  print("Waiting...");

  String name = await fetchUserNameFuture();

  print("Received: $name");
}

/*
===============================================================================
SECTION 5 - EVENT LOOP
===============================================================================

Dart uses an Event Loop.

Single-threaded by default.

Example:

main()
 ↓
event queue
 ↓
future queue
 ↓
execution

While waiting for API response:

CPU is free to execute other work.

This is why async programming scales well.

===============================================================================
*/

/*
===============================================================================
SECTION 6 - JSON PARSING
===============================================================================

JSON = String

{
  "id": 1,
  "name": "Jay"
}

Need:

jsonDecode()

===============================================================================
*/

void jsonParsingExample() {
  String jsonString = '''
  {
    "id": 1,
    "name": "Jay",
    "email": "jay@test.com"
  }
  ''';

  /*
  JSON STRING -> MAP
  */
  Map<String, dynamic> data = jsonDecode(jsonString);

  print(data);

  /*
  MAP -> OBJECT
  */
  User user = User.fromJson(data);

  print(user);

  /*
  OBJECT -> JSON
  */
  String backToJson = jsonEncode(user.toJson());

  print(backToJson);
}

/*
===============================================================================
SECTION 7 - HTTP CALLS
===============================================================================

Most common operations:

GET
POST
PUT
DELETE

Using:

package:http/http.dart

Add in pubspec.yaml:

dependencies:
  http: ^1.2.0

Run:

flutter pub get

or

dart pub get

===============================================================================
*/

Future<void> httpGetExample() async {
  print("Fetching users...");

  final response = await http.get(
    Uri.parse(
      "https://jsonplaceholder.typicode.com/users",
    ),
  );

  print("Status Code: ${response.statusCode}");

  List<dynamic> data = jsonDecode(response.body);

  User user = User.fromJson(data[0]);

  print(user);
}

/*
===============================================================================
HTTP POST
===============================================================================
*/

Future<void> httpPostExample() async {
  final response = await http.post(
    Uri.parse(
      "https://jsonplaceholder.typicode.com/posts",
    ),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "title": "Dart",
      "body": "Learning async",
      "userId": 1,
    }),
  );

  print(response.statusCode);
  print(response.body);
}

/*
===============================================================================
SECTION 8 - PARALLEL EXECUTION
===============================================================================

Suppose:

API 1 -> 2 seconds
API 2 -> 2 seconds
API 3 -> 2 seconds

Sequential:

2 + 2 + 2 = 6 seconds

Parallel:

~2 seconds

Use:

Future.wait()

===============================================================================
*/

Future<String> api1() async {
  await Future.delayed(Duration(seconds: 2));
  return "API1";
}

Future<String> api2() async {
  await Future.delayed(Duration(seconds: 2));
  return "API2";
}

Future<String> api3() async {
  await Future.delayed(Duration(seconds: 2));
  return "API3";
}

Future<void> parallelExecutionExample() async {
  print("Starting parallel calls...");

  List<String> results = await Future.wait([
    api1(),
    api2(),
    api3(),
  ]);

  print(results);
}

/*
===============================================================================
SECTION 9 - MULTITHREADING?
===============================================================================

IMPORTANT:

Dart does NOT use shared-memory threads like Java.

Java:

Thread A
Thread B
Thread C

share memory.

---------------------------------

Dart uses:

ISOLATES

Each isolate:

- Own memory
- Own event loop
- Own heap
- Own stack

No shared memory.

This eliminates race conditions.

===============================================================================
*/

/*
===============================================================================
SECTION 10 - ISOLATES
===============================================================================

Think:

New Process.

Not Thread.

Each isolate has:

Own memory space.

Communication happens through messages.

===============================================================================
*/

void isolateWorker(SendPort sendPort) {
  int sum = 0;

  for (int i = 0; i < 100000000; i++) {
    sum += i;
  }

  sendPort.send(sum);
}

Future<void> isolateExample() async {
  ReceivePort receivePort = ReceivePort();

  await Isolate.spawn(
    isolateWorker,
    receivePort.sendPort,
  );

  final result = await receivePort.first;

  print("Isolate Result: $result");
}

/*
===============================================================================
WHY ISOLATES EXIST
===============================================================================

Suppose:

Huge JSON
Image processing
Encryption
Video processing

If done on main isolate:

UI freezes.

Instead:

Main Isolate
      |
      |
      +---- Worker Isolate

Worker does CPU-heavy work.

Main remains responsive.

===============================================================================
*/

/*
===============================================================================
SECTION 11 - MEMORY MODEL OF ISOLATES
===============================================================================

Main Isolate

Heap A
Stack A

Worker Isolate

Heap B
Stack B

No shared memory.

Messages are copied between isolates.

This is safer than traditional threading.

===============================================================================
*/

/*
===============================================================================
SECTION 12 - MAIN
===============================================================================

Execution starts here.

===============================================================================
*/

Future<void> main() async {
  print("\n==============================");
  print("FUTURE EXAMPLE");
  print("==============================");

  await futureExample();

  print("\n==============================");
  print("ASYNC AWAIT");
  print("==============================");

  await asyncAwaitExample();

  print("\n==============================");
  print("JSON PARSING");
  print("==============================");

  jsonParsingExample();

  print("\n==============================");
  print("HTTP GET");
  print("==============================");

  await httpGetExample();

  print("\n==============================");
  print("HTTP POST");
  print("==============================");

  await httpPostExample();

  print("\n==============================");
  print("PARALLEL EXECUTION");
  print("==============================");

  await parallelExecutionExample();

  print("\n==============================");
  print("ISOLATE");
  print("==============================");

  await isolateExample();

  print("\n==============================");
  print("DONE");
  print("==============================");
}
