import 'package:calculator/app/routes/routes.dart';
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/basic_calculator/presentation/pages/basic_calculator_page.dart';
// Import other calculator pages...

class AppRoutes {
  static const String home = RouteNames.home;

  static Map<String, WidgetBuilder> routes = {
    RouteNames.home: (context) => const HomePage(),
    RouteNames.basicCalculator: (context) => BasicCalculatorPage(),
    // Add other routes...
  };
}