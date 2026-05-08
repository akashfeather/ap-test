import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_storage_service.dart';
import '../services/audio_player_service.dart';
import '../services/permission_service.dart';

class MusicProvider with ChangeNotifier {
  final AudioStorageService _storageService = AudioStorageService();
  final AudioPlayerService audioPlayerService = AudioPlayerService();

  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<String> _favoriteIds = [];
  List<SongModel> get favoriteSongs => _songs.where((s) => _favoriteIds.contains(s.id.toString())).toList();

  SongModel? get currentSong {
    if (audioPlayerService.player.currentIndex != null && _songs.isNotEmpty) {
      if (audioPlayerService.player.currentIndex! < _songs.length) {
         return _songs[audioPlayerService.player.currentIndex!];
      }
    }
    return null;
  }

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;
  
  String? _error;
  String? get error => _error;

  MusicProvider() {
    _init();
    audioPlayerService.player.currentIndexStream.listen((index) {
      notifyListeners();
    });
  }

  Future<void> _init() async {
    try {
      _hasPermission = await PermissionService.requestStoragePermission();
      
      if (_hasPermission) {
        _songs = await _storageService.getSongs();
      } else {
        _songs = [];
      }

      final prefs = await SharedPreferences.getInstance();
      _favoriteIds = prefs.getStringList('favorites') ?? [];
    } catch (e) {
      _error = 'Error initializing app: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPermissionAgain() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _init();
  }

  Future<void> playSong(SongModel song) async {
    try {
      int index = _songs.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        await audioPlayerService.init(_songs, index);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error playing song: $e';
      print(_error);
      notifyListeners();
    }
  }

  void toggleFavorite(SongModel song) async {
    try {
      final id = song.id.toString();
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteIds);
      notifyListeners();
    } catch (e) {
      _error = 'Error toggling favorite: $e';
      print(_error);
      notifyListeners();
    }
  }

  bool isFavorite(SongModel song) {
    return _favoriteIds.contains(song.id.toString());
  }
}
