/*
=============================================================================

FLUTTER LEARNING PLAYGROUND

HOW TO RUN

1. Open terminal

2. Start app

    flutter run -d chrome

3. Chrome opens

4. Change code

5. Save file

    Ctrl + S

6. Hot Reload happens automatically

OR

Press:

    r

inside terminal

=============================================================================

IMPORTANT FLUTTER CONCEPTS

Flutter UI = Widget Tree

Everything is a Widget:

MaterialApp
Scaffold
Column
Row
Container
Text
Icon
ListView

Think:

MaterialApp
    └── Scaffold
            └── Column
                    └── Text

=============================================================================
*/

import 'package:flutter/material.dart';

/*
=============================================================================

PROGRAM ENTRY POINT

Just like:

Python:
    if __name__ == "__main__"

Java:
    public static void main()

Go:
    func main()

Execution starts here.

=============================================================================
*/
void main() {
  runApp(const MyApp());
}

/*
=============================================================================

STATELESS WIDGET

Use when UI DOES NOT change.

Examples:

- Logo
- Header
- Static text
- About page

No mutable state.

=============================================================================
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    =====================================================================

    BUILD METHOD

    Flutter calls build() whenever widget needs rendering.

    Think:

    "How should this widget look right now?"

    =====================================================================
    */

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /*
      ===================================================================

      SCAFFOLD

      Think:

      Android Activity

      or

      HTML Page

      Provides:

      - AppBar
      - Body
      - Drawer
      - Floating Action Button

      ===================================================================
      */
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Playground"),
        ),

        /*
        ===================================================================

        BODY

        Main screen content.

        ===================================================================
        */
        body: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            sectionTitle("1. Text Widget"),

            /*
            ===============================================================

            TEXT

            Most basic widget.

            ===============================================================
            */
            const Text(
              "Hello Flutter",
              style: TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 30),

            sectionTitle("2. Container Widget"),

            /*
            ===============================================================

            CONTAINER

            Similar to:

            HTML div

            Used for:

            - size
            - color
            - padding
            - margin
            - alignment

            ===============================================================
            */
            Container(
              height: 100,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                "Container",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            sectionTitle("3. Row Widget"),

            /*
            ===============================================================

            ROW

            Horizontal layout

            ===============================================================
            */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.home),
                Icon(Icons.favorite),
                Icon(Icons.settings),
              ],
            ),

            const SizedBox(height: 30),

            sectionTitle("4. Column Widget"),

            /*
            ===============================================================

            COLUMN

            Vertical layout

            ===============================================================
            */
            Column(
              children: const [
                Text("First"),
                Text("Second"),
                Text("Third"),
              ],
            ),

            const SizedBox(height: 30),

            sectionTitle("5. Icon Widget"),

            const Icon(
              Icons.flutter_dash,
              size: 80,
            ),

            const SizedBox(height: 30),

            sectionTitle("6. Button Widget"),

            /*
            ===============================================================

            BUTTON

            User interaction.

            ===============================================================
            */
            ElevatedButton(
              onPressed: () {
                debugPrint("Button clicked");
              },
              child: const Text("Click Me"),
            ),

            const SizedBox(height: 30),

            sectionTitle("7. Card Widget"),

            /*
            ===============================================================

            CARD

            Material Design card.

            ===============================================================
            */
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Icon(Icons.person),
                    Text("John Doe"),
                    Text("Software Engineer"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            sectionTitle("8. Image Widget"),

            /*
            ===============================================================

            NETWORK IMAGE

            Loads image from URL.

            ===============================================================
            */
            Image.network(
              "https://picsum.photos/200",
              height: 150,
            ),

            const SizedBox(height: 30),

            sectionTitle("9. Expanded Widget"),

            /*
            ===============================================================

            EXPANDED

            Fills remaining space.

            Used inside Row / Column.

            ===============================================================
            */
            Container(
              height: 80,
              color: Colors.grey.shade300,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(color: Colors.red),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            sectionTitle("10. Stack Widget"),

            /*
            ===============================================================

            STACK

            Place widgets on top of each other.

            Similar to CSS position:absolute

            ===============================================================
            */
            SizedBox(
              height: 150,
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    color: Colors.blue,
                  ),
                  Positioned(
                    top: 50,
                    left: 50,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            sectionTitle("11. ListTile Widget"),

            /*
            ===============================================================

            LIST TILE

            Very common in apps.

            Settings screen.
            User lists.
            Menus.

            ===============================================================
            */
            const ListTile(
              leading: Icon(Icons.person),
              title: Text("Jay"),
              subtitle: Text("Flutter Developer"),
              trailing: Icon(Icons.arrow_forward_ios),
            ),

            const SizedBox(height: 30),

            sectionTitle("12. Padding Widget"),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                color: Colors.orange,
                height: 50,
              ),
            ),

            const SizedBox(height: 30),

            sectionTitle("13. Center Widget"),

            const Center(
              child: Text("Centered Text"),
            ),

            const SizedBox(height: 30),

            sectionTitle("14. Divider Widget"),

            const Divider(),

            const SizedBox(height: 30),

            sectionTitle("15. ListView"),

            /*
            ===============================================================

            LISTVIEW

            Scrollable list.

            Most used widget in Flutter.

            ===============================================================
            */
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: 10,

                /*
                =========================================================

                itemBuilder

                Creates rows lazily.

                Only visible rows are built.

                Efficient.

                =========================================================
                */
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Item $index"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
=============================================================================

REUSABLE WIDGET FUNCTION

Instead of repeating:

Text(
  ...
)

many times.

=============================================================================
*/
Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
