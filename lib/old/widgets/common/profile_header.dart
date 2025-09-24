import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final IconData icon;
  const ProfileHeader({
    super.key,
    required this.displayName,
    this.icon = CupertinoIcons.person,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.purple,
          child: Icon(icon, size: 60, color: AppColors.background),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}
