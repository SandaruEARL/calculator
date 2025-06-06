// Updated main.dart to use CalculatorShell
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'features/basic_calculator/calculator_shell.dart';
import 'features/basic_calculator/presentation/viewmodels/basic_calculator_viewmodel.dart';
import 'features/basic_calculator/basic_calculator_feature.dart';
import 'features/basic_calculator/presentation/viewmodels/scientific_calculator_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;
  await BasicCalculatorFeature.register(getIt);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: GetIt.instance<BasicCalculatorViewModel>(),
          ),
          ChangeNotifierProvider.value(
            value: GetIt.instance<ScientificCalculatorViewModel>(),
          ),
        ],
        child: CalculatorShell(),
      ),
    );
  }
}

typedef ShowHistoryCallback = void Function();