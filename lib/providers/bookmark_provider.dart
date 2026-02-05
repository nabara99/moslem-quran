import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../services/bookmark_service.dart';

class BookmarkProvider with ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();

  List<Bookmark> _bookmarks = [];
  Set<String> _bookmarkKeys = {};
  bool _isLoading = false;

  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;

  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    _bookmarks = await _bookmarkService.getAllBookmarks();
    _bookmarkKeys = _bookmarks.map((b) => b.bookmarkKey).toSet();

    _isLoading = false;
    notifyListeners();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarkKeys.contains('${surahNumber}_$ayahNumber');
  }

  Future<Map<String, dynamic>> toggleBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String ayahText,
  }) async {
    final key = '${surahNumber}_$ayahNumber';

    if (_bookmarkKeys.contains(key)) {
      // Remove bookmark
      final success = await _bookmarkService.removeBookmark(surahNumber, ayahNumber);
      if (success) {
        _bookmarks.removeWhere((b) =>
          b.surahNumber == surahNumber && b.ayahNumber == ayahNumber
        );
        _bookmarkKeys.remove(key);
        notifyListeners();
        return {'success': true, 'message': 'Bookmark dihapus'};
      }
      return {'success': false, 'message': 'Gagal menghapus bookmark'};
    } else {
      // Add bookmark
      final bookmark = Bookmark(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        ayahText: ayahText,
        createdAt: DateTime.now(),
      );

      final result = await _bookmarkService.addBookmark(bookmark);
      if (result['success']) {
        // Reload bookmarks to get the updated list
        await loadBookmarks();
        return result;
      }
      return result;
    }
  }

  Future<void> clearAllBookmarks() async {
    await _bookmarkService.clearAllBookmarks();
    _bookmarks.clear();
    _bookmarkKeys.clear();
    notifyListeners();
  }
}
