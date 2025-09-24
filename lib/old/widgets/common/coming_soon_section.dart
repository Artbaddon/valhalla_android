import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/utils/colors.dart';

class ComingSoonSection extends StatelessWidget {
  final String message;
  const ComingSoonSection({super.key, this.message = 'Sección próximamente'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.square_grid_2x2,
            size: 48,
            color: AppColors.purple,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.purple,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
