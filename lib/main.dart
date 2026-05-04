import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/local_db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalDbService.instance.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const SixOtuApp());
}

class SixOtuApp extends StatefulWidget {
  const SixOtuApp({super.key});

  @override
  State<SixOtuApp> createState() => _SixOtuAppState();
}

class _SixOtuAppState extends State<SixOtuApp> {
  late final _router = AppRouter.router();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '6OTU Attendance — نظام الحضور الذكي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
