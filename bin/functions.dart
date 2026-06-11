/*
==============================================================================
DART FUNCTIONS - COMPLETE LEARNING FILE
==============================================================================

This file covers:

1. Basic Functions
2. Parameters
3. Return Values
4. Optional Parameters
5. Named Parameters
6. Required Parameters
7. Arrow Functions
8. Anonymous Functions
9. Higher Order Functions
10. Functions as Variables
11. Closures
12. Recursion

Run:

dart run bin/functions.dart

==============================================================================
*/

void main() {
  print("\n================ BASIC FUNCTION ================\n");

  sayHello();

  print("\n================ PARAMETERS ================\n");

  greetUser("Jay");
  greetUser("John");

  print("\n================ RETURN VALUE ================\n");

  int result = add(10, 20);
  print("Result: $result");

  print("\n================ OPTIONAL POSITIONAL ================\n");

  createUser("Jay");
  createUser("Jay", 30);

  print("\n================ NAMED PARAMETERS ================\n");

  createEmployee(
    name: "Jay",
    age: 28,
  );

  print("\n================ REQUIRED PARAMETERS ================\n");

  createAccount(
    username: "jay123",
    password: "secret",
  );

  print("\n================ ARROW FUNCTION ================\n");

  print(square(5));

  print("\n================ FUNCTION VARIABLE ================\n");

  var operation = multiply;

  print(operation(5, 4));

  print("\n================ ANONYMOUS FUNCTION ================\n");

  List<String> names = ["Jay", "John", "Sara"];

  names.forEach((name) {
    print(name);
  });

  print("\n================ HIGHER ORDER FUNCTION ================\n");

  executeOperation(10, 5, addNumbers);

  print("\n================ CLOSURE ================\n");

  var counter = createCounter();

  counter();
  counter();
  counter();

  print("\n================ RECURSION ================\n");

  print("Factorial 5 = ${factorial(5)}");
}

/*
==============================================================================
1. BASIC FUNCTION
==============================================================================

A function is a reusable block of code.

Syntax:

returnType functionName() {
    code
}

*/

void sayHello() {
  print("Hello Dart!");
}

/*
==============================================================================
2. FUNCTION WITH PARAMETERS
==============================================================================

Parameters are inputs passed into a function.

*/

void greetUser(String name) {
  print("Hello $name");
}

/*
==============================================================================
3. FUNCTION WITH RETURN VALUE
==============================================================================

Return sends a value back to caller.

*/

int add(int a, int b) {
  return a + b;
}

/*
==============================================================================
4. OPTIONAL POSITIONAL PARAMETERS
==============================================================================

Placed inside []

Can be omitted when calling.

*/

void createUser(String name, [int? age]) {
  print("Name: $name");
  print("Age: $age");
}

/*
==============================================================================
5. NAMED PARAMETERS
==============================================================================

Placed inside {}

Makes function calls easier to read.

*/

void createEmployee({
  String? name,
  int? age,
}) {
  print("Employee Name: $name");
  print("Employee Age: $age");
}

/*
==============================================================================
6. REQUIRED PARAMETERS
==============================================================================

required keyword forces caller to provide value.

*/

void createAccount({
  required String username,
  required String password,
}) {
  print("Username: $username");
  print("Password: $password");
}

/*
==============================================================================
7. ARROW FUNCTION
==============================================================================

Short syntax for one-line functions.

*/

int square(int number) => number * number;

/*
==============================================================================
8. FUNCTION AS VARIABLE
==============================================================================

Functions are first-class citizens in Dart.

Can be stored in variables.

*/

int multiply(int a, int b) {
  return a * b;
}

/*
==============================================================================
9. HIGHER ORDER FUNCTION
==============================================================================

A function that receives another function.

Very common in Flutter.

*/

int addNumbers(int a, int b) {
  return a + b;
}

void executeOperation(
  int a,
  int b,
  int Function(int, int) operation,
) {
  print(operation(a, b));
}

/*
==============================================================================
10. CLOSURES
==============================================================================

A closure remembers variables from its parent scope.

*/

Function createCounter() {
  int count = 0;

  return () {
    count++;
    print("Count = $count");
  };
}

/*
==============================================================================
11. RECURSION
==============================================================================

Function calling itself.

Useful for:
- Trees
- Graphs
- File systems
- Algorithms

*/

int factorial(int number) {
  if (number <= 1) {
    return 1;
  }

  return number * factorial(number - 1);
}
