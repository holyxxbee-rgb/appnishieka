import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../models/user_profile.dart';

class DiaryProvider with ChangeNotifier {
  static const String _entriesKey = 'snapdiary_entries';
  static const String _profileKey = 'snapdiary_profile';

  List<DiaryEntry> _entries = [];
  UserProfile _profile = UserProfile(
    firstName: 'Sarah',
    lastName: 'Jenkins',
    email: 'sarah.jenkins@gmail.com',
    bio: 'Capturing golden moments, quiet rain, and chamomile thoughts 🌸☕',
    diaryTitle: "Sarah's Quiet Sanctuary",
    memoryMilestone: 'April 14',
    reminderTime: '8:30 PM',
    notebookRuledLines: true,
  );
  bool _isLoading = true;

  List<DiaryEntry> get entries => List.unmodifiable(_entries);
  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  List<DiaryEntry> get favorites =>
      _entries.where((entry) => entry.isFavorite).toList();

  DiaryProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load entries
      final entriesJsonStr = prefs.getString(_entriesKey);
      if (entriesJsonStr != null && entriesJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(entriesJsonStr);
        _entries = decoded.map((item) => DiaryEntry.fromJson(item)).toList();
      } else {
        // Initialize with default rich starter entries matching the Stitch design
        _entries = [
          DiaryEntry(
            id: '1',
            title: 'Cozy Rain & Cinnamon Latte',
            content:
                'Spent the afternoon listening to the gentle rain against the window with my sketchbook and a warm handmade ceramic mug. Wrapped myself in the oatmeal wool throw, ground fresh espresso beans with roasted cinnamon, and penned thoughts before anyone else awoke.',
            date: DateTime.now(),
            mood: 'Cozy',
            moodEmoji: '☕',
            imageUrl:
                'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
            tags: ['cozy', 'rainydays'],
            isFavorite: true,
          ),
          DiaryEntry(
            id: '2',
            title: 'Morning Botanical Walk',
            content:
                'Found the most delicate blush peonies blooming near the old greenhouse fountain. The conservatory had just opened. Sunlight poured through Victorian cast-iron frames, catching the fine mist around the ferns.',
            date: DateTime.now().subtract(const Duration(days: 1)),
            mood: 'Inspired',
            moodEmoji: '🌸',
            imageUrl:
                'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=600&q=80',
            tags: ['nature', 'peace'],
            isFavorite: false,
          ),
          DiaryEntry(
            id: '3',
            title: 'Weekend Recipe Experiments',
            content:
                'Finally mastered the French strawberry tart recipe with vanilla cream glaze. Kitchen smelled like sugar and absolute heaven! Saved two slices for Claire’s tea visit tomorrow.',
            date: DateTime.now().subtract(const Duration(days: 3)),
            mood: 'Joyful',
            moodEmoji: '🌸',
            imageUrl:
                'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80',
            tags: ['baking', 'milestone'],
            isFavorite: true,
          ),
        ];
        await _saveEntriesToPrefs();
      }

      // Load profile
      final profileJsonStr = prefs.getString(_profileKey);
      if (profileJsonStr != null && profileJsonStr.isNotEmpty) {
        _profile = UserProfile.fromJson(jsonDecode(profileJsonStr));
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveEntriesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, encoded);
  }

  Future<void> _saveProfileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_profile.toJson());
    await prefs.setString(_profileKey, encoded);
  }

  Future<void> addEntry(DiaryEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _saveEntriesToPrefs();
  }

  Future<void> updateEntry(DiaryEntry updated) async {
    final index = _entries.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _entries[index] = updated;
      notifyListeners();
      await _saveEntriesToPrefs();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveEntriesToPrefs();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index].isFavorite = !_entries[index].isFavorite;
      notifyListeners();
      await _saveEntriesToPrefs();
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _saveProfileToPrefs();
  }

  Future<void> clearAllData() async {
    _entries.clear();
    _profile = UserProfile(
      firstName: 'Sarah',
      lastName: 'Jenkins',
      email: 'sarah.jenkins@gmail.com',
      bio: 'Capturing golden moments, quiet rain, and chamomile thoughts 🌸☕',
      diaryTitle: "Sarah's Quiet Sanctuary",
      memoryMilestone: 'April 14',
      reminderTime: '8:30 PM',
      notebookRuledLines: true,
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    await prefs.remove(_profileKey);
  }
}
