import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'now_playing_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Music")),
    const Center(child: Text("Repeat")),
    const LibraryScreen(),
    const Center(child: Text("Settings")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.globalBackground,
        ),
        child: Stack(
          children: [
            // Current Screen
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            
            // Bottom floating UI
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniPlayer(),
                  const SizedBox(height: 12),
                  _buildBottomNavBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      borderRadius: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon(Icons.home_filled, 0),
          _navIcon(Icons.music_note, 1),
          _navIcon(Icons.repeat, 2),
          _navIcon(Icons.library_music, 3),
          _navIcon(Icons.settings, 4),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.accentLime.withOpacity(0.2),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? AppColors.accentLime : AppColors.secondaryText,
          size: 28,
        ),
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;

    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const NowPlayingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 24,
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.purpleGradientEnd.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Title & Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Controls
            IconButton(
               icon: StreamBuilder<bool>(
                 stream: provider.audioPlayerService.player.playingStream,
                 builder: (context, snapshot) {
                   final playing = snapshot.data ?? false;
                   return Icon(
                     playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                     color: AppColors.accentLime,
                     size: 36,
                   );
                 },
               ),
               onPressed: () {
                  final playing = provider.audioPlayerService.player.playing;
                  if (playing) {
                     provider.audioPlayerService.pause();
                  } else {
                     provider.audioPlayerService.play();
                  }
               },
            ),
          ],
        ),
      ),
    );
  }
}
