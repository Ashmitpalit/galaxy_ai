import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/photo_model.dart';

// Provider for saved pins (photos) state
final savedPinsProvider = StateNotifierProvider<SavedPinsNotifier, Map<String, PhotoModel>>((ref) {
  return SavedPinsNotifier();
});

class SavedPinsNotifier extends StateNotifier<Map<String, PhotoModel>> {
  SavedPinsNotifier() : super({}) {
    _loadPins();
  }

  static const String _storageKey = 'saved_pins';

  // Load pins from storage
  Future<void> _loadPins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinsJson = prefs.getString(_storageKey);
      
      if (pinsJson != null) {
        final Map<String, dynamic> decoded = json.decode(pinsJson);
        state = decoded.map((key, value) => MapEntry(key, PhotoModel.fromJson(value)));
      }
    } catch (e) {
      // Handle error
      state = {};
    }
  }

  // Save pins to storage
  Future<void> _savePins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinsJson = json.encode(
        state.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_storageKey, pinsJson);
    } catch (e) {
      // Handle error
    }
  }

  // Save a pin (add to state)
  Future<void> savePin(PhotoModel photo) async {
    final pinId = photo.id.toString();
    state = {...state, pinId: photo};
    await _savePins();
  }

  // Unsave a pin (remove from state)
  Future<void> unsavePin(String pinId) async {
    final newState = Map<String, PhotoModel>.from(state);
    newState.remove(pinId);
    state = newState;
    await _savePins();
  }

  // Check if pin is saved
  bool isPinned(String pinId) {
    return state.containsKey(pinId);
  }

  // Get all saved pins as list
  List<PhotoModel> getAllPins() {
    return state.values.toList();
  }

  // Get pin by ID
  PhotoModel? getPinById(String pinId) {
    return state[pinId];
  }
}
