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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeAdminPage(),
    );
  }
}

class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

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
        child: ListView(
          children: [
            // Card 1
            _buildInfoCard(
              title: "Nuevas Amenidades",
              description:
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                  "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                  "when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              image: "asstes/img/megafono.png", 
            ),
            const SizedBox(height: 16),

            // Card 2
            _buildInfoCard(
              title: "Mantenimiento Programado",
              description:
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                  "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                  "when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              image: "asstes/img/herramienta.png", // herramientas
            ),
          ],
        ),
      ),
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

  Widget _buildInfoCard({
    required String title,
    required String description,
    required String image,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: lila,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(image, height: 40, width: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: purple),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Leer más",
                  style: TextStyle(color: background),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
