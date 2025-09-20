import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/utils/theme.dart';
import 'package:valhalla_android/utils/app_router.dart';
import 'package:valhalla_android/services/api_service.dart';
import 'package:valhalla_android/services/storage_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  ApiService().initialize();

  runApp(const ValhallaApp());
}

class ValhallaApp extends StatefulWidget {
  const ValhallaApp({super.key});

  @override
  State<ValhallaApp> createState() => _ValhallaAppState();
}

class _ValhallaAppState extends State<ValhallaApp> {
  // We rebuild router when auth provider changes via GoRouter refreshListenable logic
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..initializeAuth(),
      builder: (ctx, _) {
        final router = AppRouter.createRouter(ctx);

        return MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          title: 'Valhalla',
         

        );
        
      },
    );
  }
}
