// basic_calculator_feature.dart (Feature Module Registration)
import 'package:calculator/features/basic_calculator/presentation/viewmodels/scientific_calculator_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/calculation_local_datasource.dart';
import 'data/repositores/calculation_repository_impl.dart';
import 'domain/repositories/calculation_repository.dart';
import 'domain/services/expresion_evaluator.dart';
import 'domain/usecases/calculate.dart';
import 'domain/usecases/calculate_live.dart';
import 'domain/usecases/clear_history.dart';
import 'domain/usecases/get_calculation_history.dart';
import 'domain/usecases/save_calculation.dart';
import 'presentation/viewmodels/basic_calculator_viewmodel.dart';

class BasicCalculatorFeature {
  static Future<void> register(GetIt getIt) async {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);

    // Data sources
    getIt.registerLazySingleton<CalculationLocalDataSource>(
          () => CalculationLocalDataSourceImpl(
        sharedPreferences: getIt(),
      ),
    );

    // Register ExpressionEvaluator **before** repository
    getIt.registerLazySingleton(() => ExpressionEvaluator());

    // Repositories
    getIt.registerLazySingleton<CalculationRepository>(
          () => CalculationRepositoryImpl(
        localDataSource: getIt(), evaluator: getIt(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton(() => Calculate(getIt()));
    getIt.registerLazySingleton(() => SaveCalculation(getIt()));
    getIt.registerLazySingleton(() => GetCalculationHistory(getIt()));
    getIt.registerLazySingleton(() => ClearHistory(getIt()));
    getIt.registerLazySingleton(() => CalculateLive(getIt()));


    // View models
    getIt.registerLazySingleton(
          () => BasicCalculatorViewModel(
        calculate: getIt(),
        saveCalculation: getIt(),
        getCalculationHistory: getIt(),
        clearHistory: getIt(), calculateLive:getIt(),
      ),
    );

    getIt.registerLazySingleton(
          () => ScientificCalculatorViewModel(
        calculate: getIt(),
        saveCalculation: getIt(),
        getCalculationHistory: getIt(),
        clearHistory: getIt(), calculateLive:getIt(),
      ),
    );
  }
}