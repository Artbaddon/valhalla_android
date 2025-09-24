import 'package:flutter/material.dart';
import 'core/services/storage_service.dart';
import 'core/network/dio_client.dart';
import 'core/services/navigation_service.dart';
import 'core/constants/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await StorageService.instance.init();
  await DioClient.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DependencyInjection.setupProviders(
      child: MaterialApp(
        title: 'Valhalla Android',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
