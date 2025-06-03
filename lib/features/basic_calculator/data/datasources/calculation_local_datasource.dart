// data/datasources/calculation_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/faliures/calculation_faliures.dart';
import '../models/calculation_model.dart';

abstract class CalculationLocalDataSource {
  Future<List<CalculationModel>> getCalculationHistory();
  Future<void> saveCalculation(CalculationModel calculation);
  Future<void> clearHistory();
}

class CalculationLocalDataSourceImpl implements CalculationLocalDataSource {
  static const String CALCULATION_HISTORY_KEY = 'calculation_history';
  final SharedPreferences sharedPreferences;

  CalculationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CalculationModel>> getCalculationHistory() async {
    try {
      final jsonString = sharedPreferences.getString(CALCULATION_HISTORY_KEY);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => CalculationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw StorageFailure('Failed to load calculation history');
    }
  }

  @override
  Future<void> saveCalculation(CalculationModel calculation) async {
    try {
      final currentHistory = await getCalculationHistory();
      currentHistory.add(calculation);

      // Keep only last 50 calculations
      if (currentHistory.length > 50) {
        currentHistory.removeRange(0, currentHistory.length - 50);
      }

      final jsonString = json.encode(
        currentHistory.map((calc) => calc.toJson()).toList(),
      );
      await sharedPreferences.setString(CALCULATION_HISTORY_KEY, jsonString);
    } catch (e) {
      throw StorageFailure('Failed to save calculation');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await sharedPreferences.remove(CALCULATION_HISTORY_KEY);
    } catch (e) {
      throw StorageFailure('Failed to clear history');
    }
  }
}
