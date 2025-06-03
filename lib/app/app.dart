import 'package:calculator/app/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Calculator App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,

    );
  }
}