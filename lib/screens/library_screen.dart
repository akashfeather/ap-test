import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/music_provider.dart';
import '../utils/app_colors.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<String> _tabs = ['All', 'Playlists', 'Liked Songs', 'Downloaded'];
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildSongList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryText, size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const Text(
                'My Music',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryText),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isActive = _activeTab == index;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentLime : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive ? AppColors.accentLime : AppColors.glassBorder,
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isActive ? Colors.black : AppColors.secondaryText,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSongList() {
    final provider = context.watch<MusicProvider>();
    
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentLime),
      );
    }

    List<SongModel> songsToShow = provider.songs;
    if (_activeTab == 2) {
      songsToShow = provider.favoriteSongs;
    }

    if (songsToShow.isEmpty) {
      return const Center(
        child: Text(
          "No music found",
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: songsToShow.length,
      itemBuilder: (context, index) {
        final song = songsToShow[index];
        bool isCurrentSong = provider.currentSong?.id == song.id;
        bool isPlaying = provider.audioPlayerService.player.playing && isCurrentSong;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white54),
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrentSong ? AppColors.accentLime : AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            song.artist ?? "Unknown artist",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          trailing: IconButton(
            icon: Icon(
              isCurrentSong && isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: isCurrentSong ? AppColors.accentLime : AppColors.primaryText,
              size: 36,
            ),
            onPressed: () {
              if (isCurrentSong) {
                if (isPlaying) {
                  provider.audioPlayerService.pause();
                } else {
                  provider.audioPlayerService.play();
                }
              } else {
                provider.playSong(song);
              }
            },
          ),
          onTap: () {
            provider.playSong(song);
          },
        );
      },
    );
  }
}
