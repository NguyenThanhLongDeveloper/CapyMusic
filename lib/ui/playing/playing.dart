import 'package:flutter/material.dart';

import '../../data/model/song.dart';

/// Widget bao bọc cho màn hình đang phát nhạc.
class Playing extends StatelessWidget {
  const Playing({super.key, required this.playingSong, required this.songs});
  
  /// Bài hát hiện đang được chọn để phát.
  final Song playingSong;
  /// Danh sách tất cả các bài hát để có thể chuyển bài.
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return PlayingPage(
      songs: songs,
      playingSong: playingSong
    );
  }
}

/// Trang hiển thị giao diện chi tiết khi đang phát một bài hát.
class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key, required this.songs, required this.playingSong});
  
  final Song playingSong;
  final List<Song> songs;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Playing'), // Hiển thị tạm thời văn bản "Playing".
      ),
    );
  }
}
