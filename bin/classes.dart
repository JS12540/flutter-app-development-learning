/*
============================================================
DART LEARNING FILE
============================================================

Think of this file as a playground.

Run using:

dart run bin/classes.dart

Topics covered:

1. Variables
2. Data Types
3. Lists
4. Maps
5. Functions
6. Optional Parameters
7. Classes
8. Constructors
9. Named Constructors
10. Getters & Setters
11. Static Members
12. Inheritance
13. Polymorphism
14. Abstract Classes
15. Interfaces
16. Null Safety
17. Final vs Const
18. Memory Concepts
19. Object Lifecycle
20. String Interpolation

============================================================
*/

void main() {
  print("\n========== VARIABLES ==========\n");

  variablesExample();

  print("\n========== LISTS ==========\n");

  listsExample();

  print("\n========== MAPS ==========\n");

  mapsExample();

  print("\n========== FUNCTIONS ==========\n");

  functionsExample();

  print("\n========== CLASSES ==========\n");

  classesExample();

  print("\n========== INHERITANCE ==========\n");

  inheritanceExample();

  print("\n========== ABSTRACT ==========\n");

  abstractExample();

  print("\n========== NULL SAFETY ==========\n");

  nullSafetyExample();
}

//////////////////////////////////////////////////////////////
// VARIABLES
//////////////////////////////////////////////////////////////

void variablesExample() {
  String name = "Jay";

  int age = 25;

  double salary = 1000.50;

  bool isActive = true;

  print(name);
  print(age);
  print(salary);
  print(isActive);

  /*
  var

  Dart infers the type automatically.
  */

  var city = "London";

  print(city);

  /*
  final

  Assigned once.
  Runtime value.
  */

  final currentTime = DateTime.now();

  print(currentTime);

  /*
  const

  Compile-time constant.
  */

  const pi = 3.14159;

  print(pi);
}

//////////////////////////////////////////////////////////////
// LISTS
//////////////////////////////////////////////////////////////

void listsExample() {
  /*
  List = Array
  */

  List<String> fruits = [
    "Apple",
    "Banana",
    "Orange"
  ];

  print(fruits);

  print(fruits[0]);

  fruits.add("Mango");

  print(fruits);

  for (String fruit in fruits) {
    print(fruit);
  }
}

//////////////////////////////////////////////////////////////
// MAPS
//////////////////////////////////////////////////////////////

void mapsExample() {
  /*
  Map = Dictionary / JSON Object
  */

  Map<String, dynamic> user = {
    "name": "Jay",
    "age": 25,
    "active": true
  };

  print(user);

  print(user["name"]);

  user["city"] = "London";

  print(user);
}

//////////////////////////////////////////////////////////////
// FUNCTIONS
//////////////////////////////////////////////////////////////

void functionsExample() {
  int result = add(10, 20);

  print(result);

  greet("Jay");

  greetWithCountry(
    name: "Jay",
    country: "UK",
  );
}

int add(int a, int b) {
  return a + b;
}

void greet(String name) {
  print("Hello $name");
}

/*
Named parameters

Very common in Flutter
*/

void greetWithCountry({
  required String name,
  required String country,
}) {
  print("$name from $country");
}

//////////////////////////////////////////////////////////////
// CLASSES
//////////////////////////////////////////////////////////////

class User {
  String name;
  int age;

  /*
  Constructor

  Called when object is created
  */

  User(this.name, this.age);

  void introduce() {
    print("My name is $name");
  }
}

void classesExample() {
  User user = User("Jay", 25);

  print(user.name);

  user.introduce();
}

//////////////////////////////////////////////////////////////
// MEMORY CONCEPT
//////////////////////////////////////////////////////////////

/*
IMPORTANT

Stack:
Stores local variables and references.

Heap:
Stores actual objects.

Example:

User user = User("Jay", 25);

STACK

user ---> memory address

HEAP

User Object
name = Jay
age = 25

The variable does NOT contain the object.

It contains a reference
(pointer-like concept).
*/

//////////////////////////////////////////////////////////////
// NAMED CONSTRUCTORS
//////////////////////////////////////////////////////////////

class Product {
  String name;
  double price;

  Product(this.name, this.price);

  /*
  Named Constructor
  */

  Product.free()
      : name = "Free Product",
        price = 0;
}

//////////////////////////////////////////////////////////////
// GETTERS AND SETTERS
//////////////////////////////////////////////////////////////

class BankAccount {
  double _balance = 0;

  /*
  Getter
  */

  double get balance {
    return _balance;
  }

  /*
  Setter
  */

  set deposit(double amount) {
    _balance += amount;
  }
}

//////////////////////////////////////////////////////////////
// STATIC
//////////////////////////////////////////////////////////////

class MathUtils {
  static const double pi = 3.14159;

  static int add(int a, int b) {
    return a + b;
  }
}

/*
Usage

MathUtils.pi
MathUtils.add(...)
*/

//////////////////////////////////////////////////////////////
// INHERITANCE
//////////////////////////////////////////////////////////////

class Animal {
  void eat() {
    print("Animal Eating");
  }
}

class Dog extends Animal {
  void bark() {
    print("Woof");
  }
}

void inheritanceExample() {
  Dog dog = Dog();

  dog.eat();

  dog.bark();
}

//////////////////////////////////////////////////////////////
// POLYMORPHISM
//////////////////////////////////////////////////////////////

class Vehicle {
  void start() {
    print("Vehicle Start");
  }
}

class Car extends Vehicle {
  @override
  void start() {
    print("Car Start");
  }
}

//////////////////////////////////////////////////////////////
// ABSTRACT CLASS
//////////////////////////////////////////////////////////////

abstract class Payment {
  void processPayment();
}

class StripePayment extends Payment {
  @override
  void processPayment() {
    print("Stripe Payment");
  }
}

void abstractExample() {
  StripePayment payment = StripePayment();

  payment.processPayment();
}

//////////////////////////////////////////////////////////////
// INTERFACE
//////////////////////////////////////////////////////////////

/*
Dart has no "interface" keyword.

Every class can be used as an interface.
*/

class Flyable {
  void fly() {}
}

class Bird implements Flyable {
  @override
  void fly() {
    print("Bird Flying");
  }
}

//////////////////////////////////////////////////////////////
// NULL SAFETY
//////////////////////////////////////////////////////////////

void nullSafetyExample() {
  /*
  Cannot be null
  */

  String name = "Jay";

  print(name);

  /*
  Can be null
  */

  String? middleName;

  print(middleName);

  middleName = "K";

  print(middleName);

  /*
  Null Coalescing
  */

  String result = middleName ?? "Default";

  print(result);

  /*
  Force unwrap

  Dangerous
  */

  print(middleName!);
}

//////////////////////////////////////////////////////////////
// FINAL VS CONST
//////////////////////////////////////////////////////////////

/*

FINAL

Runtime constant

Example:

final currentTime = DateTime.now();

Value known at runtime.


CONST

Compile-time constant

Example:

const pi = 3.14;

Value known before execution.

*/

//////////////////////////////////////////////////////////////
// OBJECT LIFECYCLE
//////////////////////////////////////////////////////////////

/*

Object Creation

User user = User("Jay",25);

1. Memory allocated on Heap
2. Constructor runs
3. Object returned
4. Reference stored

When no references remain:

user = null;

Garbage Collector eventually removes object.

Dart uses automatic garbage collection.

You never manually free memory.

*/

//////////////////////////////////////////////////////////////
// STRING INTERPOLATION
//////////////////////////////////////////////////////////////

/*

String name = "Jay";

print("Hello $name");

print("2 + 2 = ${2 + 2}");

Very common in Flutter UI.

*/
