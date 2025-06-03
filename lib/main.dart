import 'package:calculator/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'features/basic_calculator/presentation/pages/basic_calculator_page.dart';
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
        child: BasicCalculatorPage(),
      ),
    );
  }
}