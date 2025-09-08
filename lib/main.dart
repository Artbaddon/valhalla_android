import 'package:flutter/material.dart';
import 'package:valhalla_android/config/app_theme.dart';
import 'package:valhalla_android/config/app_routes_fixed.dart';

void main() {
  runApp(const ValhallaApp());
}
  
class ValhallaApp extends StatelessWidget {
  const ValhallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valhalla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
