import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/utils/theme.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/services/api_service.dart';
import 'package:valhalla_android/services/storage_service.dart';
import 'package:valhalla_android/services/navigation_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  ApiService().initialize();

  runApp(const ValhallaApp());
}

class ValhallaApp extends StatelessWidget {
  const ValhallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..initializeAuth(),
      child: MaterialApp(
        navigatorKey: NavigationService.instance.navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        title: 'Valhalla',
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.login,
      ),
    );
  }
}
