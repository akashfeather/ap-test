import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayer get player => _audioPlayer;

  Future<void> init(List<SongModel> songs, int initialIndex) async {
    await _playlist.clear();
    final audioSources = songs.map((song) => AudioSource.uri(
      Uri.parse(song.uri ?? ''),
      tag: MediaItem(
        id: song.id.toString(),
        album: song.album ?? 'Unknown Album',
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
      ),
    )).toList();
    
    await _playlist.addAll(audioSources);
    await _audioPlayer.setAudioSource(_playlist, initialIndex: initialIndex);
    _audioPlayer.play();
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();
  void next() => _audioPlayer.seekToNext();
  void previous() => _audioPlayer.seekToPrevious();
  
  Future<void> setShuffleMode(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeatMode(LoopMode mode) async {
    await _audioPlayer.setLoopMode(mode);
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
}
