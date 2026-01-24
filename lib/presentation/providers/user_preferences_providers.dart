import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/photo_model.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Search History Notifier
class SearchHistoryNotifier extends StateNotifier<Map<String, int>> {
  final SharedPreferences? _prefs;
  static const _key = 'search_history_v1';
  
  // Default globally popular tags (Initial state)
  static const List<String> _defaults = [
    'Nature', 'Backgrounds', 'Travel', 'Fashion', 'Animals', 'Technology', 'Art'
  ];

  SearchHistoryNotifier(this._prefs) : super({}) {
    _loadHistory();
  }

  void _loadHistory() {
    if (_prefs == null) return;
    final jsonString = _prefs.getString(_key);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        // invalid data, ignore
      }
    }
  }

  Future<void> addSearch(String query) async {
    if (_prefs == null || query.trim().isEmpty) return;
    
    final normalized = query.toLowerCase().trim();
    final currentCount = state[normalized] ?? 0;
    
    final newState = Map<String, int>.from(state);
    newState[normalized] = currentCount + 1;
    
    state = newState;
    await _prefs.setString(_key, jsonEncode(newState));
  }
  
  List<String> getTopSearches(int limit) {
    if (state.isEmpty) return _defaults.take(limit).toList();
    
    final sortedEntries = state.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending by count
      
    final topUserTerms = sortedEntries.map((e) => e.key).take(limit).toList();
    
    // Fill remaining slots with defaults if user has few searches
    if (topUserTerms.length < limit) {
      for (final def in _defaults) {
        if (!topUserTerms.contains(def)) {
           topUserTerms.add(def);
           if (topUserTerms.length >= limit) break;
        }
      }
    }
    
    return topUserTerms;
  }

  List<String> getRecentSearches(int limit) {
    if (state.isEmpty) return [];
    
    // For chronological order, we'd need timestamps
    // For now, return by frequency as a proxy (most searched = most recent usage pattern)
    final sortedEntries = state.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return sortedEntries.map((e) => e.key).take(limit).toList();
  }

  Future<void> clearAll() async {
    if (_prefs == null) return;
    
    state = {};
    await _prefs.setString(_key, jsonEncode({}));
  }
}

// Discovered Tags Notifier (Live Trends)
class DiscoveredTagsNotifier extends StateNotifier<List<String>> {
  DiscoveredTagsNotifier() : super([]);

  void extractTagsFromPhotos(List<PhotoModel> photos) {
    final Set<String> newTags = {};
    final stopWords = {
      'the', 'a', 'an', 'in', 'on', 'at', 'of', 'and', 'with', 'by',
      'photo', 'picture', 'image', 'free', 'stock', 'download', 'hd', '4k'
    };
    
    for (final photo in photos) {
      if (photo.alt != null && photo.alt!.isNotEmpty) {
        // Simple extraction: split by space, clean, filter
        final words = photo.alt!.toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
            .split(' ');
            
        for (final word in words) {
          if (word.length > 3 && !stopWords.contains(word)) {
            // Capitalize first letter for display
            final capitalized = word[0].toUpperCase() + word.substring(1);
            newTags.add(capitalized);
          }
        }
      }
    }
    
    // If we found new tags, shuffle them in (simple trend simulation)
    if (newTags.isNotEmpty) {
      // Keep existing discovered tags, add new ones, take top 10 unique
      final uniqueCombined = {...state, ...newTags}.take(10).toList();
      state = uniqueCombined;
    }
  }
}

final discoveredTagsProvider = StateNotifierProvider<DiscoveredTagsNotifier, List<String>>((ref) {
  return DiscoveredTagsNotifier();
});

// Provider that waits for SharedPreferences to be ready
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, Map<String, int>>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return SearchHistoryNotifier(prefsAsync.valueOrNull);
});

// Dynamic Home Tabs Provider
final homeTabsProvider = Provider<List<String>>((ref) {
  final historyNotifier = ref.watch(searchHistoryProvider.notifier);
  // Watch history
  ref.watch(searchHistoryProvider); 
  // Watch discovered tags
  final discoveredTags = ref.watch(discoveredTagsProvider);
  
  // 1. Get Top User Searches (includes strict defaults)
  final topSearches = historyNotifier.getTopSearches(5);
  
  // 2. Combine: All -> Top Searches -> Discovered Tags
  // We prioritize User History/Defaults, then append new Discoveries
  final combined = <String>{'All', ...topSearches, ...discoveredTags};
  
  return combined.toList();
});
