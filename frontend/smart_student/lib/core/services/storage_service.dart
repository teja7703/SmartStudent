import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final p = await prefs;
    await p.setString(AppConstants.userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final p = await prefs;
    final data = p.getString(AppConstants.userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> clearUser() async {
    final p = await prefs;
    await p.remove(AppConstants.userKey);
  }

  Future<Set<String>> getBookmarkedStories() async {
    final p = await prefs;
    return p.getStringList(AppConstants.bookmarksKey)?.toSet() ?? {};
  }

  Future<void> toggleBookmark(String storyId) async {
    final p = await prefs;
    final bookmarks = await getBookmarkedStories();
    if (bookmarks.contains(storyId)) {
      bookmarks.remove(storyId);
    } else {
      bookmarks.add(storyId);
    }
    await p.setStringList(AppConstants.bookmarksKey, bookmarks.toList());
  }

  Future<bool> isBookmarked(String storyId) async {
    final bookmarks = await getBookmarkedStories();
    return bookmarks.contains(storyId);
  }

  Future<void> saveReadProgress(String storyId, double progress) async {
    final p = await prefs;
    final key = '${AppConstants.readProgressKey}_$storyId';
    await p.setDouble(key, progress);
  }

  Future<double> getReadProgress(String storyId) async {
    final p = await prefs;
    final key = '${AppConstants.readProgressKey}_$storyId';
    return p.getDouble(key) ?? 0.0;
  }
}
