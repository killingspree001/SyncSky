import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/example_model.dart';

// ============================================================================
// EXAMPLE PROVIDER WITH PERSISTENCE
// Replace with your own providers
// ============================================================================

class ExampleNotifier extends Notifier<List<ExampleModel>> {
  static const _storageKey = 'example_data';

  @override
  List<ExampleModel> build() {
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey);
    if (data != null && data.isNotEmpty) {
      state = data.map((item) => ExampleModel.fromMap(jsonDecode(item))).toList();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_storageKey, data);
  }

  void add(ExampleModel item) {
    state = [...state, item];
    _saveToStorage();
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveToStorage();
  }

  void clear() {
    state = [];
    _saveToStorage();
  }
}

final exampleProvider = NotifierProvider<ExampleNotifier, List<ExampleModel>>(
  ExampleNotifier.new,
);

// ============================================================================
// SIMPLE STATE PROVIDER EXAMPLE
// ============================================================================

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// ============================================================================
// DERIVED PROVIDER EXAMPLE
// ============================================================================

final itemCountProvider = Provider<int>((ref) {
  return ref.watch(exampleProvider).length;
});
