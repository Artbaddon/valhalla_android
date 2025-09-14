import 'package:flutter/material.dart';

const Color accentColor = Color(0xFF6A5ACD);
const Color lightBackground = Color(0xFFE6E6FA);

class ParkingOwnerScreen extends StatelessWidget {
  const ParkingOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        title: const Text(
          'Valhalla',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: accentColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestión Parqueaderos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterSection(),
              const SizedBox(height: 16),
              _buildParkingList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Parqueo'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Pagos'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archivos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ordenar por',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Restablecer',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParkingList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildParkingCard(
          title: 'Parqueadero A-101',
          status: 'Ocupado',
          description: 'Torre 1 - APT 101',
        ),
        _buildParkingCard(
          title: 'Parqueadero A-102',
          status: 'Vacío',
          description: 'Torre 1 - APT 102',
        ),
        _buildParkingCard(
          title: 'Parqueadero A-103',
          status: 'En mantenimiento',
          description: 'Torre 1 - APT 103',
        ),
        _buildParkingCard(
          title: 'Parqueadero B-201',
          status: 'Ocupado',
          description: 'Torre 2 - APT 201',
        ),
      ],
    );
  }

  Widget _buildParkingCard({
    required String title,
    required String status,
    required String description,
  }) {
    Color statusColor;
    switch (status) {
      case 'Ocupado':
        statusColor = Colors.red;
        break;
      case 'Vacío':
        statusColor = Colors.green;
        break;
      case 'En mantenimiento':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Estado: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      status,
                      style: TextStyle(color: statusColor),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}