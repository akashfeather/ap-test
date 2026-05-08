import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../providers/music_provider.dart';
import '../utils/app_colors.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;

    if (song == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundTop,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("No song playing")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.isFavorite(song) ? Icons.favorite : Icons.favorite_border,
              color: provider.isFavorite(song) ? AppColors.accentLime : Colors.white,
            ),
            onPressed: () => provider.toggleFavorite(song),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            artworkWidth: double.infinity,
            artworkHeight: double.infinity,
            artworkFit: BoxFit.cover,
            nullArtworkWidget: Container(color: AppColors.backgroundTop),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.backgroundTop.withOpacity(0.6),
                      AppColors.backgroundBottom.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Album Art Circular
                  Hero(
                    tag: 'album_art_${song.id}',
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          artworkWidth: 280,
                          artworkHeight: 280,
                          artworkFit: BoxFit.cover,
                          nullArtworkWidget: Container(
                            color: AppColors.purpleGradientEnd.withOpacity(0.3),
                            child: const Icon(Icons.music_note, color: Colors.white54, size: 80),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Title and Artist
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Lyrics Preview (Dummy)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Lyrics available soon...",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                  const Spacer(),
                  // Progress Bar
                  StreamBuilder<Duration>(
                    stream: provider.audioPlayerService.player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = provider.audioPlayerService.player.duration ?? Duration.zero;
                      return ProgressBar(
                        progress: position,
                        total: duration,
                        progressBarColor: AppColors.accentLime,
                        baseBarColor: Colors.white.withOpacity(0.2),
                        thumbColor: AppColors.accentLime,
                        timeLabelTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        onSeek: (duration) {
                          provider.audioPlayerService.seek(duration);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Main Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                        onPressed: provider.audioPlayerService.previous,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (provider.audioPlayerService.player.playing) {
                            provider.audioPlayerService.pause();
                          } else {
                            provider.audioPlayerService.play();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.accentLime,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentLime.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: StreamBuilder<bool>(
                            stream: provider.audioPlayerService.player.playingStream,
                            builder: (context, snapshot) {
                              final playing = snapshot.data ?? false;
                              return Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 48,
                              );
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                        onPressed: provider.audioPlayerService.next,
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.white54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
