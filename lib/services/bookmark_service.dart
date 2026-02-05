import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class BookmarkService {
  static const String _bookmarkKey = 'bookmarks';
  static const int maxBookmarks = 5;

  Future<List<Bookmark>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString(_bookmarkKey);

      if (bookmarksJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(bookmarksJson);
      return decoded.map((item) => Bookmark.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> addBookmark(Bookmark bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getAllBookmarks();

      // Check if bookmark already exists
      final exists = bookmarks.any((b) =>
        b.surahNumber == bookmark.surahNumber &&
        b.ayahNumber == bookmark.ayahNumber
      );

      if (exists) {
        return {'success': false, 'message': 'Bookmark sudah ada'};
      }

      bool replacedOldest = false;
      // If max capacity reached, remove the oldest bookmark
      if (bookmarks.length >= maxBookmarks) {
        bookmarks.removeAt(0); // Remove oldest (first in list)
        replacedOldest = true;
      }

      bookmarks.add(bookmark);
      final encoded = json.encode(bookmarks.map((b) => b.toJson()).toList());
      await prefs.setString(_bookmarkKey, encoded);

      return {
        'success': true,
        'replacedOldest': replacedOldest,
        'message': replacedOldest
          ? 'Bookmark ditambahkan. Bookmark terlama dihapus karena sudah mencapai maksimal 5 bookmark.'
          : 'Bookmark berhasil ditambahkan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan bookmark'};
    }
  }

  Future<bool> removeBookmark(int surahNumber, int ayahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getAllBookmarks();

      bookmarks.removeWhere((b) =>
        b.surahNumber == surahNumber &&
        b.ayahNumber == ayahNumber
      );

      final encoded = json.encode(bookmarks.map((b) => b.toJson()).toList());
      await prefs.setString(_bookmarkKey, encoded);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getAllBookmarks();
    return bookmarks.any((b) =>
      b.surahNumber == surahNumber &&
      b.ayahNumber == ayahNumber
    );
  }

  Future<bool> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarkKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}
