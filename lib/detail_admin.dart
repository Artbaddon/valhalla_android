import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const ValhallaApp());
}

const background =  Color.fromRGBO(243, 243, 255, 1);
const blue =  Color.fromRGBO(48, 51, 146, 1);
const purple =  Color.fromRGBO(73, 76, 162, 1);
const lila =  Color.fromRGBO(198, 203, 239, 1);

class ValhallaApp extends StatelessWidget {
  const ValhallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetailAdminPage(),
    );
  }
}

class DetailAdminPage extends StatelessWidget {
  const DetailAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        centerTitle: true,
        title: const Text(
          "Valhalla",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: purple,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.bell,
              color: purple,
              size: 28,
            ),
          ),
        ],
      ),

      // BODY
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botón retroceso
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: purple,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card con info
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: lila,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        const Center(
                          child: Text(
                            "Nuevas Amenidades",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Icono megáfono
                        Center(
                          child: Image.network(
                            "asstes/img/megafono.png",
                            height: 60,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Texto largo
                        const Text(
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                          "when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n\n"
                          "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of "
                          "classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, "
                          "a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words.",
                          style: TextStyle(
                            fontSize: 14,
                            color: purple,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: background,
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.car),
            label: "Car",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar_circle),
            label: "Money",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: "Group",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube_box),
            label: "Box",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
