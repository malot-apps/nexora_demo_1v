import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../models/playlist_model.dart';

/// Storage Service wrapping [SharedPreferences].
/// Persists app configuration, bookmarks, favorites, and playlists locally.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Saves the list of user imported playlists.
  Future<bool> savePlaylists(List<PlaylistModel> playlists) async {
    final listJson = playlists.map((p) => p.toJson()).toList();
    final rawString = json.encode(listJson);
    return _prefs.setString(AppConstants.prefPlaylistsKey, rawString);
  }

  /// Loads imported playlists from disk.
  List<PlaylistModel> loadPlaylists() {
    final rawString = _prefs.getString(AppConstants.prefPlaylistsKey);
    if (rawString == null || rawString.isEmpty) return [];

    try {
      final List<dynamic> listJson = json.decode(rawString) as List<dynamic>;
      return listJson.map((item) => PlaylistModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves the ID of the playlist currently selected by the user.
  Future<bool> saveActivePlaylistId(String id) async {
    return _prefs.setString(AppConstants.prefActivePlaylistId, id);
  }

  /// Loads the active playlist ID if any.
  String? loadActivePlaylistId() {
    return _prefs.getString(AppConstants.prefActivePlaylistId);
  }

  /// Adds a channel to favorites list.
  Future<bool> toggleFavoriteChannel(String channelId, bool isFav) async {
    final List<String> favs = _prefs.getStringList(AppConstants.prefFavoritesKey) ?? [];
    if (isFav) {
      if (!favs.contains(channelId)) favs.add(channelId);
    } else {
      favs.remove(channelId);
    }
    return _prefs.setStringList(AppConstants.prefFavoritesKey, favs);
  }

  /// Gets the list of favorite channel IDs.
  List<String> getFavorites() {
    return _prefs.getStringList(AppConstants.prefFavoritesKey) ?? [];
  }
}
