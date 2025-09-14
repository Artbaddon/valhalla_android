import 'package:flutter/material.dart';

const Color primaryColor = Color.fromRGBO(129, 134, 213, 1);
const Color secondaryColor = Color.fromRGBO(73, 76, 162, 1);
const Color textColor = Color.fromRGBO(243, 243, 255, 1);
const Color accentColor = Color(0xFF6A5ACD);
const Color lightBackground = Color(0xFFE6E6FA);

class ParkingAdminScreen extends StatelessWidget {
  const ParkingAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180.0),
        child: AppBar(
          backgroundColor: lightBackground,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valhalla',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications, color: accentColor),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gestión Parqueaderos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar navegación al filtro
                        },
                        icon: const Icon(Icons.filter_list, color: textColor),
                        label: const Text('Filtros', style: TextStyle(color: textColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParkingSection(
                title: 'Parqueaderos de Residentes',
                items: [
                  _buildParkingCard(
                    imagePath: 'assets/peugeot_208.png',
                    title: 'Parqueadero A-103',
                    subtitle: 'Vacío',
                    isResident: true,
                  ),
                  _buildParkingCard(
                    imagePath: 'assets/peugeot_3008.png',
                    title: 'Parqueadero A-101',
                    subtitle: 'Torre 1 - APT 101',
                    isResident: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildParkingSection(
                title: 'Parqueaderos de Visitantes',
                items: [
                  _buildParkingCard(
                    imagePath: 'assets/classic_car.png',
                    title: 'Parqueadero C-202',
                    subtitle: 'Vacío',
                    isResident: false,
                  ),
                  _buildParkingCard(
                    imagePath: 'assets/red_car.png',
                    title: 'Parqueadero C-205',
                    subtitle: 'Torre 1 - APT 101',
                    isResident: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildParkingSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: secondaryColor),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildParkingCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required bool isResident,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.asset(
                imagePath,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isResident ? 'Residente' : 'Visitante',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!isResident)
                        GestureDetector(
                          onTap: () {
                            // TODO: Implementar lógica de reserva
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle_outline, color: accentColor, size: 20),
                              SizedBox(width: 4),
                              Text('Reservar', style: TextStyle(color: accentColor)),
                            ],
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implementar lógica de vista
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.remove_red_eye_outlined, color: accentColor, size: 20),
                            SizedBox(width: 4),
                            Text('Ver', style: TextStyle(color: accentColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}