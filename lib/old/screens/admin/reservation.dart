import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/widgets/navigation/app_bottom_nav.dart';

// Admin module: Reservation screen (renamed from detail duplication example)

class ReservationAdminPage extends StatefulWidget {
  const ReservationAdminPage({super.key});

  @override
  State<ReservationAdminPage> createState() => _ReservationAdminPageState();
}

class _ReservationAdminPageState extends State<ReservationAdminPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'Valhalla',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.purple,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.bell,
              color: AppColors.purple,
              size: 28,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.purple,
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.lila,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Nuevas Amenidades',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'assets/img/megafono.png',
                            height: 60,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n\nContrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.purple,
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        isAdmin: true,
        onTap: (i) {
          setState(() => _tab = i);
          // Navigation handling can go here
        },
      ),
    );
  }
}
