import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/music_provider.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _tabs = ['All', 'New Release', 'Trending', 'Top'];
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTabs(),
              const SizedBox(height: 32),
              
              if (provider.error != null) ...[
                _buildError(provider),
                const SizedBox(height: 24),
              ],
              
              if (!provider.hasPermission)
                _buildPermissionRequest(provider)
              else if (provider.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.accentLime))
              else if (provider.songs.isNotEmpty) ...[
                _buildDiscoverCard(provider.songs.first, provider),
                const SizedBox(height: 32),
                _buildTopPlaylists(provider),
              ] else
                const Center(child: Text("No music found on this device", style: TextStyle(color: AppColors.secondaryText))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(MusicProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚠️ Error",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? "Unknown error",
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest(MusicProvider provider) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.folder_off, size: 64, color: AppColors.secondaryText),
          const SizedBox(height: 16),
          const Text("Storage permission needed", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.requestPermissionAgain(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentLime),
            child: const Text("Allow Access", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Andrew',
              style: TextStyle(color: AppColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.search, color: AppColors.primaryText), onPressed: () {}),
            IconButton(icon: const Icon(Icons.favorite_border, color: AppColors.primaryText), onPressed: () {}),
          ],
        )
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isActive = _activeTab == index;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentLime : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isActive ? AppColors.accentLime : AppColors.glassBorder),
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

  Widget _buildDiscoverCard(SongModel song, MusicProvider provider) {
    return GestureDetector(
      onTap: () => provider.playSong(song),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.purpleCardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.purpleGradientEnd.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discover weekly', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Listen to ${song.title}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: AppColors.accentLime, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Icon(provider.isFavorite(song) ? Icons.favorite : Icons.favorite_border,
                          color: provider.isFavorite(song) ? AppColors.accentLime : Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            // Album art from device
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Container(color: Colors.black26, child: const Icon(Icons.music_note, color: Colors.white54, size: 40)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopPlaylists(MusicProvider provider) {
    // Show next 4 songs as playlists for visuals if playlists run empty
    final songsToShow = provider.songs.skip(1).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top daily tracks', style: TextStyle(color: AppColors.primaryText, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListView.builder(
          itemCount: songsToShow.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final song = songsToShow[index];
            bool isCurrentSong = provider.currentSong?.id == song.id;
            bool isPlaying = provider.audioPlayerService.player.playing && isCurrentSong;

            return GestureDetector(
              onTap: () => provider.playSong(song),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: AppColors.glassBackground, borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: isCurrentSong ? AppColors.accentLime : AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(song.artist ?? 'Various Artists', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isCurrentSong && isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                        color: isCurrentSong ? AppColors.accentLime : AppColors.primaryText, size: 32),
                      onPressed: () {
                        if (isCurrentSong) {
                          if (isPlaying) provider.audioPlayerService.pause();
                          else provider.audioPlayerService.play();
                        } else {
                          provider.playSong(song);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
