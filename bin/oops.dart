/*
============================================================
DART OOP COMPLETE GUIDE
============================================================

Topics:
1. Public variables and methods
2. Private variables and methods
3. Encapsulation
4. Getters and setters
5. Constructors
6. Named constructors
7. Static variables and methods
8. Inheritance
9. Method overriding
10. Polymorphism
11. Abstract classes
12. Interfaces
13. Composition
14. Aggregation
15. Mixins
16. Final class concepts
17. Memory concepts
18. Real Flutter-style class structure

IMPORTANT:
Dart does NOT use public/private keywords.

Instead:

public  = normal name
private = name starts with underscore _

Example:

String name;      // public
String _password; // private to this file/library
*/

void main() {
  print("\n========== PUBLIC ==========");
  publicExample();

  print("\n========== PRIVATE ==========");
  privateExample();

  print("\n========== ENCAPSULATION ==========");
  encapsulationExample();

  print("\n========== CONSTRUCTORS ==========");
  constructorExample();

  print("\n========== STATIC ==========");
  staticExample();

  print("\n========== INHERITANCE ==========");
  inheritanceExample();

  print("\n========== POLYMORPHISM ==========");
  polymorphismExample();

  print("\n========== ABSTRACT CLASS ==========");
  abstractExample();

  print("\n========== INTERFACE ==========");
  interfaceExample();

  print("\n========== COMPOSITION ==========");
  compositionExample();

  print("\n========== MIXIN ==========");
  mixinExample();
}

/*
============================================================
1. PUBLIC VARIABLES AND METHODS
============================================================

In Dart, everything is public by default.

If a variable or method does NOT start with _, it can be accessed
from outside the class.
*/

class PublicUser {
  String name;
  int age;

  PublicUser(this.name, this.age);

  void sayHello() {
    print("Hello, my name is $name");
  }
}

void publicExample() {
  PublicUser user = PublicUser("Jay", 25);

  print(user.name);
  print(user.age);

  user.sayHello();
}

/*
============================================================
2. PRIVATE VARIABLES AND METHODS
============================================================

Dart private members start with _

Important:
Private in Dart means private to the file/library, NOT private only
to the class like Java/C++.

Example:
_name is private.
_calculateSalary() is private.
*/

class PrivateUser {
  String name;

  String _password;

  PrivateUser(this.name, this._password);

  void showUser() {
    print("User: $name");
    _showPasswordLength();
  }

  void _showPasswordLength() {
    print("Password length: ${_password.length}");
  }
}

void privateExample() {
  PrivateUser user = PrivateUser("Jay", "secret123");

  print(user.name);

  user.showUser();

  // This works inside the same file.
  // But from another Dart file, _password will not be accessible.
  print(user._password);
}

/*
============================================================
3. ENCAPSULATION
============================================================

Encapsulation means:
- Keep data private
- Expose controlled methods to read/update it

Instead of allowing direct modification:

account.balance = -500;

we protect balance using _balance.
*/

class BankAccount {
  double _balance = 0;

  double get balance {
    return _balance;
  }

  void deposit(double amount) {
    if (amount <= 0) {
      print("Deposit amount must be positive");
      return;
    }

    _balance += amount;
  }

  void withdraw(double amount) {
    if (amount <= 0) {
      print("Withdraw amount must be positive");
      return;
    }

    if (amount > _balance) {
      print("Insufficient balance");
      return;
    }

    _balance -= amount;
  }
}

void encapsulationExample() {
  BankAccount account = BankAccount();

  account.deposit(1000);
  account.withdraw(200);

  print(account.balance);

  // account._balance = -9999;
  // Bad idea. In another file, this would not be accessible.
}

/*
============================================================
4. CONSTRUCTORS
============================================================

Constructor runs when object is created.

Example:

User user = User("Jay");

The constructor initializes the object.
*/

class Customer {
  String name;
  int age;

  Customer(this.name, this.age);

  Customer.guest()
      : name = "Guest",
        age = 0;

  Customer.fromMap(Map<String, dynamic> data)
      : name = data["name"],
        age = data["age"];

  void show() {
    print("Customer: $name, age: $age");
  }
}

void constructorExample() {
  Customer c1 = Customer("Jay", 25);
  c1.show();

  Customer c2 = Customer.guest();
  c2.show();

  Customer c3 = Customer.fromMap({
    "name": "Amit",
    "age": 30,
  });
  c3.show();
}

/*
============================================================
5. STATIC VARIABLES AND METHODS
============================================================

Static belongs to the class, not the object.

You do not need to create an object.

Example:

AppConfig.appName
MathHelper.add(1, 2)
*/

class AppConfig {
  static String appName = "Learning App";

  static void showAppName() {
    print(appName);
  }
}

class MathHelper {
  static int add(int a, int b) {
    return a + b;
  }
}

void staticExample() {
  print(AppConfig.appName);

  AppConfig.showAppName();

  print(MathHelper.add(10, 20));
}

/*
============================================================
6. INHERITANCE
============================================================

Inheritance means one class gets properties/methods from another class.

Parent/Base class:
Animal

Child/Derived class:
Dog

Dog extends Animal.
*/

class Animal {
  String name;

  Animal(this.name);

  void eat() {
    print("$name is eating");
  }
}

class Dog extends Animal {
  Dog(String name) : super(name);

  void bark() {
    print("$name says woof");
  }
}

void inheritanceExample() {
  Dog dog = Dog("Tommy");

  dog.eat();
  dog.bark();
}

/*
============================================================
7. METHOD OVERRIDING
============================================================

Child class can replace parent class behavior using @override.
*/

class Vehicle {
  void start() {
    print("Vehicle starting");
  }
}

class Car extends Vehicle {
  @override
  void start() {
    print("Car starting with key/button");
  }
}

class Bike extends Vehicle {
  @override
  void start() {
    print("Bike starting with self-start");
  }
}

/*
============================================================
8. POLYMORPHISM
============================================================

Polymorphism means:
same parent type, different child behavior.

Vehicle v = Car();
Vehicle v = Bike();

Calling start() gives different output.
*/

void polymorphismExample() {
  List<Vehicle> vehicles = [
    Car(),
    Bike(),
  ];

  for (Vehicle vehicle in vehicles) {
    vehicle.start();
  }
}

/*
============================================================
9. ABSTRACT CLASS
============================================================

Abstract class cannot be directly created.

It defines rules for child classes.

Use when:
- You want common structure
- You want subclasses to implement required methods
*/

abstract class Payment {
  void pay(double amount);

  void paymentStarted() {
    print("Payment started");
  }
}

class CardPayment extends Payment {
  @override
  void pay(double amount) {
    print("Paid $amount using card");
  }
}

class UpiPayment extends Payment {
  @override
  void pay(double amount) {
    print("Paid $amount using UPI");
  }
}

void abstractExample() {
  Payment payment = CardPayment();

  payment.paymentStarted();
  payment.pay(500);

  payment = UpiPayment();
  payment.pay(1000);
}

/*
============================================================
10. INTERFACE
============================================================

Dart does not have an interface keyword.

Any class can be used as an interface using implements.

Difference:

extends:
- Inherits behavior
- Can reuse parent code

implements:
- Must provide all methods/fields yourself
- Acts like a contract
*/

class Logger {
  void log(String message) {
    print(message);
  }
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) {
    print("Console log: $message");
  }
}

void interfaceExample() {
  ConsoleLogger logger = ConsoleLogger();

  logger.log("User logged in");
}

/*
============================================================
11. COMPOSITION
============================================================

Composition means:
A class HAS another class.

Example:
Car HAS Engine.

Instead of inheritance:

Car extends Engine  // wrong design

Use:

Car has Engine      // better design
*/

class Engine {
  void startEngine() {
    print("Engine started");
  }
}

class MyCar {
  Engine engine;

  MyCar(this.engine);

  void startCar() {
    engine.startEngine();
    print("Car started");
  }
}

void compositionExample() {
  Engine engine = Engine();

  MyCar car = MyCar(engine);

  car.startCar();
}

/*
============================================================
12. AGGREGATION
============================================================

Aggregation is similar to composition.

Difference:

Composition:
Object strongly owns another object.

Example:
House has Rooms.
If House is destroyed, Rooms usually do not matter.

Aggregation:
Object uses another object, but does not fully own it.

Example:
Team has Players.
Players can exist without Team.
*/

class Player {
  String name;

  Player(this.name);
}

class Team {
  String name;
  List<Player> players;

  Team(this.name, this.players);

  void showPlayers() {
    for (Player player in players) {
      print("${player.name} plays for $name");
    }
  }
}

/*
============================================================
13. MIXINS
============================================================

Mixin lets you reuse methods in multiple classes
without normal inheritance.

Use with keyword: with
*/

mixin CanFly {
  void fly() {
    print("Flying");
  }
}

mixin CanSwim {
  void swim() {
    print("Swimming");
  }
}

class Duck with CanFly, CanSwim {
  void sound() {
    print("Quack");
  }
}

void mixinExample() {
  Duck duck = Duck();

  duck.fly();
  duck.swim();
  duck.sound();
}

/*
============================================================
14. FINAL VARIABLES IN CLASSES
============================================================

final means value assigned once.

Good for immutable objects.
*/

class ImmutableUser {
  final String name;
  final int age;

  ImmutableUser({
    required this.name,
    required this.age,
  });
}

/*
============================================================
15. CONST CONSTRUCTOR
============================================================

Used when object can be created at compile-time.

Very common in Flutter widgets.

Example:

const Text("Hello")
const SizedBox(height: 20)
*/

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);
}

/*
============================================================
16. MEMORY CONCEPTS
============================================================

When you write:

User user = User("Jay");

What happens?

1. Object is created in Heap memory
2. user variable stores reference to that object
3. The object remains alive while something references it
4. When no reference exists, Garbage Collector removes it

Dart has automatic memory management.

You do not manually free memory.
*/

class MemoryUser {
  String name;

  MemoryUser(this.name);
}

void memoryExample() {
  MemoryUser u1 = MemoryUser("Jay");

  MemoryUser u2 = u1;

  u2.name = "Amit";

  print(u1.name);

  /*
  Output: Amit

  Why?

  u1 and u2 point to the same object in memory.
  */
}

/*
============================================================
17. VALUE TYPES VS REFERENCE TYPES
============================================================

Simple values like int, double, bool, String behave like values.

Objects and Lists behave like references.

Example:

List<int> a = [1, 2, 3];
List<int> b = a;

b.add(4);

print(a); // [1, 2, 3, 4]

Both variables point to the same list object.
*/

void referenceExample() {
  List<int> a = [1, 2, 3];

  List<int> b = a;

  b.add(4);

  print(a);
}

/*
============================================================
18. COPY OBJECTS SAFELY
============================================================

If you do not want to modify original object,
create a copy.
*/

class Profile {
  final String name;
  final int age;

  Profile({
    required this.name,
    required this.age,
  });

  Profile copyWith({
    String? name,
    int? age,
  }) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

void copyExample() {
  Profile p1 = Profile(name: "Jay", age: 25);

  Profile p2 = p1.copyWith(age: 26);

  print(p1.age);
  print(p2.age);
}

/*
============================================================
19. FLUTTER-STYLE MODEL CLASS
============================================================

In Flutter apps, you often create model classes like this.

Example:
API returns JSON.
You convert JSON into Dart object.
*/

class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
    };
  }
}

/*
============================================================
20. FACTORY CONSTRUCTOR
============================================================

factory constructor can return an object.

Useful for:
- JSON parsing
- Singleton
- Conditional object creation
*/

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({
    required this.success,
    required this.message,
  });

  factory ApiResponse.success(String message) {
    return ApiResponse(
      success: true,
      message: message,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      message: message,
    );
  }
}

/*
============================================================
21. SINGLETON PATTERN
============================================================

Singleton means only one object exists.

Useful for:
- App config
- API client
- Database helper
*/

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  void connect() {
    print("Database connected");
  }
}

/*
============================================================
22. OOP SUMMARY
============================================================

Class:
Blueprint.

Object:
Real instance created from class.

Encapsulation:
Hide data and expose safe methods.

Abstraction:
Hide implementation details and expose essential behavior.

Inheritance:
Child class gets parent class behavior.

Polymorphism:
Same method call behaves differently for different objects.

Interface:
Contract that class must follow.

Composition:
Build class using other classes.

Mixin:
Share reusable behavior across multiple classes.

Static:
Belongs to class, not object.

Final:
Assigned once.

Private:
Starts with underscore _

Public:
Normal variable/method name.
*/
