/*
|--------------------------------------------------------------------------
| variables.dart
|--------------------------------------------------------------------------
|
| Run:
|   dart run bin/variables.dart
|
| Goal:
| Learn the most important Dart fundamentals:
|
| 1. Variables
| 2. Data Types
| 3. Type Inference (var)
| 4. final vs const
| 5. String Interpolation
| 6. Lists
| 7. Maps
| 8. Sets
| 9. Dynamic
| 10. Null Safety
| 11. Operators
| 12. Type Checking
|
|--------------------------------------------------------------------------
*/

void main() {
  print("========== DART VARIABLES ==========\n");

  /*
  --------------------------------------------------------------------------
  1. STRING
  --------------------------------------------------------------------------

  Used for text.
  */

  String firstName = "Jay";
  String lastName = "Shah";

  print("First Name: $firstName");
  print("Last Name: $lastName");

  /*
  --------------------------------------------------------------------------
  2. INTEGER
  --------------------------------------------------------------------------

  Whole numbers.
  */

  int age = 30;
  int employees = 100;

  print("\nAge: $age");
  print("Employees: $employees");

  /*
  --------------------------------------------------------------------------
  3. DOUBLE
  --------------------------------------------------------------------------

  Decimal numbers.
  */

  double salary = 75000.50;
  double taxRate = 0.25;

  print("\nSalary: $salary");
  print("Tax Rate: $taxRate");

  /*
  --------------------------------------------------------------------------
  4. BOOLEAN
  --------------------------------------------------------------------------

  true / false values.
  */

  bool isLoggedIn = true;
  bool isAdmin = false;

  print("\nLogged In: $isLoggedIn");
  print("Admin: $isAdmin");

  /*
  --------------------------------------------------------------------------
  5. VAR
  --------------------------------------------------------------------------

  Dart automatically figures out the type.

  Once assigned, the type cannot change.
  */

  var city = "London";
  var population = 9000000;

  print("\nCity: $city");
  print("Population: $population");

  /*
  This will NOT compile:

  city = 123;

  Because city is inferred as String.
  */

  /*
  --------------------------------------------------------------------------
  6. DYNAMIC
  --------------------------------------------------------------------------

  Can change type at runtime.

  Use sparingly.
  */

  dynamic data = "Hello";

  print("\nDynamic Value: $data");

  data = 100;

  print("Dynamic Changed: $data");

  data = true;

  print("Dynamic Changed Again: $data");

  /*
  --------------------------------------------------------------------------
  7. FINAL
  --------------------------------------------------------------------------

  Assigned ONCE at runtime.

  Good when value is known only during execution.
  */

  final currentYear = DateTime.now().year;

  print("\nCurrent Year: $currentYear");

  /*
  Not allowed:

  currentYear = 2026;
  */

  /*
  --------------------------------------------------------------------------
  8. CONST
  --------------------------------------------------------------------------

  Compile-time constant.

  Must be known before program runs.
  */

  const companyName = "Modulr";

  print("Company: $companyName");

  /*
  Not allowed:

  const year = DateTime.now().year;
  */

  /*
  --------------------------------------------------------------------------
  9. STRING INTERPOLATION
  --------------------------------------------------------------------------

  Inject variables inside strings.
  */

  String name = "Jay";
  int years = 5;

  print("\nHello $name");

  print("$name has $years years of experience");

  /*
  Expressions inside strings.
  */

  print("Next year age: ${age + 1}");

  /*
  --------------------------------------------------------------------------
  10. MULTI-LINE STRINGS
  --------------------------------------------------------------------------
  */

  String description = '''
This is line 1
This is line 2
This is line 3
''';

  print("\nMulti-line String:");
  print(description);

  /*
  --------------------------------------------------------------------------
  11. LIST
  --------------------------------------------------------------------------

  Similar to Array in other languages.
  */

  List<String> fruits = [
    "Apple",
    "Banana",
    "Orange",
  ];

  print("\nFirst Fruit: ${fruits[0]}");

  fruits.add("Mango");

  print("All Fruits: $fruits");

  print("Total Fruits: ${fruits.length}");

  /*
  Mixed types using dynamic.
  */

  List<dynamic> mixed = [
    "Jay",
    30,
    true,
    5000.50,
  ];

  print("\nMixed List: $mixed");

  /*
  --------------------------------------------------------------------------
  12. MAP
  --------------------------------------------------------------------------

  Similar to Dictionary / JSON Object.
  */

  Map<String, dynamic> user = {
    "id": 1,
    "name": "Jay",
    "email": "jay@example.com",
    "isActive": true,
  };

  print("\nUser Map:");
  print(user);

  print("User Name: ${user["name"]}");

  /*
  Add new key/value.
  */

  user["country"] = "UK";

  print("Updated User:");
  print(user);

  /*
  --------------------------------------------------------------------------
  13. SET
  --------------------------------------------------------------------------

  Unique values only.
  */

  Set<String> skills = {
    "Dart",
    "Flutter",
    "API",
    "Flutter", // duplicate ignored
  };

  print("\nSkills:");
  print(skills);

  /*
  --------------------------------------------------------------------------
  14. NULL SAFETY
  --------------------------------------------------------------------------

  One of Dart's most important features.
  */

  String? middleName;

  print("\nMiddle Name:");
  print(middleName);

  middleName = "K";

  print("Updated Middle Name:");
  print(middleName);

  /*
  Nullable variable.

  String? means:
  String OR null
  */

  /*
  --------------------------------------------------------------------------
  15. NULL COALESCING OPERATOR
  --------------------------------------------------------------------------

  Use default value if null.
  */

  String? nickname;

  String displayName = nickname ?? "Guest";

  print("\nDisplay Name: $displayName");

  /*
  --------------------------------------------------------------------------
  16. TYPE CHECKING
  --------------------------------------------------------------------------
  */

  print("\nType Checks:");

  print(name is String);
  print(age is int);
  print(salary is double);

  /*
  --------------------------------------------------------------------------
  17. BASIC OPERATORS
  --------------------------------------------------------------------------
  */

  int a = 10;
  int b = 3;

  print("\nOperators:");

  print("Addition: ${a + b}");
  print("Subtraction: ${a - b}");
  print("Multiplication: ${a * b}");
  print("Division: ${a / b}");
  print("Modulo: ${a % b}");

  /*
  --------------------------------------------------------------------------
  18. COMPARISON OPERATORS
  --------------------------------------------------------------------------
  */

  print("\nComparisons:");

  print(a > b);
  print(a < b);
  print(a == b);
  print(a != b);

  /*
  --------------------------------------------------------------------------
  19. LOGICAL OPERATORS
  --------------------------------------------------------------------------
  */

  bool isVerified = true;
  bool hasSubscription = false;

  print("\nLogical:");

  print(isVerified && hasSubscription);
  print(isVerified || hasSubscription);
  print(!isVerified);

  /*
  --------------------------------------------------------------------------
  20. RUNTIME TYPE
  --------------------------------------------------------------------------
  */

  print("\nRuntime Types:");

  print(name.runtimeType);
  print(age.runtimeType);
  print(salary.runtimeType);
  print(user.runtimeType);

  /*
  --------------------------------------------------------------------------
  SUMMARY
  --------------------------------------------------------------------------
  */

  print("\n========== SUMMARY ==========");

  print("""
Learned:
✓ String
✓ int
✓ double
✓ bool
✓ var
✓ dynamic
✓ final
✓ const
✓ String interpolation
✓ List
✓ Map
✓ Set
✓ Null Safety
✓ Operators
✓ Type Checking
✓ Runtime Types
""");
}
