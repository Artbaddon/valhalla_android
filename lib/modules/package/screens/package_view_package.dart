import 'package:flutter/material.dart';
import 'package:valhalla_android/config/app_colors.dart';

class ViewPackagesPage extends StatelessWidget {
  const ViewPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> data = [
      {'name': 'Samuel Peterson', 'position': 'Software Engineer'},
      {'name': 'Megan Watson', 'position': 'Product Designer'},
      {'name': 'Olivia Bradley', 'position': 'PR Specialist'},
      {'name': 'Arnold Armstrong', 'position': 'Data Analyst'},
      {'name': 'Carla Rodriguez', 'position': 'Project Manager'},
      {'name': 'Frank Johnson', 'position': 'Program Manager'},
      {'name': 'Jennifer Goldberg', 'position': 'Art Director'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paquetes"),
        backgroundColor: AppColors.purple,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda + filtro
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.lila,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      // TODO: lógica de filtros
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de paquetes
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // sombra grisácea
                        spreadRadius: 2, // qué tanto se expande
                        blurRadius: 6, // difuminado
                        offset: const Offset(
                          0,
                          3,
                        ), // dirección de la sombra (x, y)
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.purple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['position']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: AppColors.purple,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
