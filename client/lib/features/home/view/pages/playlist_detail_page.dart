import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/features/home/models/song_model.dart';
import '../../../../core/providers/current_song_notifier.dart';
import '../../../../core/providers/playlist_notifier.dart';
import '../../models/playlist_model.dart';
import '../widgets/music_slab.dart';

class PlaylistDetailPage extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage> {
  bool _isLoading = true;
  Playlist? _playlist;

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetails();
  }

  Future<void> _loadPlaylistDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Get playlist from the notifier
    final playlistsNotifier = ref.read(playlistsNotifierProvider.notifier);
    final playlist = playlistsNotifier.getPlaylistById(widget.playlistId);

    setState(() {
      _playlist = playlist;
      _isLoading = false;
    });
  }

  void _playPlaylist() {
    if (_playlist?.songs.isNotEmpty == true) {
      final firstSong = _playlist!.songs.first;
      ref.read(currentSongNotifierProvider.notifier).updateSong(firstSong);
    }
  }

  void _playSong(Song song) {
    ref.read(currentSongNotifierProvider.notifier).updateSong(song);
  }

  Future<void> _removeSongFromPlaylist(String songId) async {
    final playlistsNotifier = ref.read(playlistsNotifierProvider.notifier);
    final success = await playlistsNotifier.removeSongFromPlaylist(
      widget.playlistId,
      songId,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song removed from playlist'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh playlist details
      _loadPlaylistDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove song'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // int selectedIndex = 0;
    // final pages = const [SongsPage(), LibraryPage(), SearchPage()];
    final currentSong = ref.watch(currentSongNotifierProvider);
    final currentSongNotifier = ref.watch(currentSongNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // pages[selectedIndex],
          const Positioned(bottom: 0, child: MusicSlab()),

          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              )
              : _playlist == null
              ? const Center(
                child: Text(
                  'Playlist not found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
              : CustomScrollView(
                slivers: [
                  // App Bar with Playlist Info
                  SliverAppBar(
                    expandedHeight: 350,
                    pinned: true,
                    backgroundColor: const Color(0xFF121212),
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF1DB954), Color(0xFF121212)],
                            stops: [0.0, 0.8],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Playlist Cover
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFF1DB954),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.queue_music,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Playlist Type
                              const Text(
                                'PLAYLIST',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Playlist Name
                              Text(
                                _playlist!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              if (_playlist!.description.isNotEmpty)
                                Text(
                                  _playlist!.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Song Count
                              Text(
                                '${_playlist!.song_count} songs',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Play Controls
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Play Button
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1DB954),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed:
                                  _playlist!.songs.isNotEmpty
                                      ? _playPlaylist
                                      : null,
                              icon:
                                 Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                        size: 32,
                                      ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Shuffle Button
                          IconButton(
                            onPressed: () {
                              currentSongNotifier.toggleShuffle();
                            },
                            icon: Icon(
                              Icons.shuffle,
                              color:
                                  currentSongNotifier.isShuffle
                                      ? const Color(0xFF1DB954)
                                      : Colors.white.withOpacity(0.7),
                              size: 28,
                            ),
                          ),
                          const Spacer(),
                          // More Options
                          IconButton(
                            onPressed: () {
                              // Show more options
                            },
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Songs List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (_playlist!.songs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.music_note_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No songs in this playlist',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final song = _playlist!.songs[index];
                        final isCurrentSong = currentSong?.id == song.id;
                        final isPlaying =
                            currentSongNotifier.isPlaying && isCurrentSong;

                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(currentSongNotifierProvider.notifier)
                                .updateSong(song);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: NetworkImage(song.thumbnail_url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child:
                                  isCurrentSong
                                      ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      )
                                      : null,
                            ),
                            title: Text(
                              song.song_name,
                              style: TextStyle(
                                color:
                                    isCurrentSong
                                        ? const Color(0xFF1DB954)
                                        : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              color: const Color(0xFF282828),
                              onSelected: (value) {
                                if (value == 'remove') {
                                  _removeSongFromPlaylist(song.id);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Remove from playlist',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                            onTap: () {
                              if (isCurrentSong) {
                                currentSongNotifier.playPause();
                              } else {
                                _playSong(song);
                              }
                            },
                          ),
                        );
                      },
                      childCount:
                          _playlist!.songs.isEmpty
                              ? 1
                              : _playlist!.songs.length,
                    ),
                  ),

                  // Bottom Padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
        ],
      ),
    );
  }
}
