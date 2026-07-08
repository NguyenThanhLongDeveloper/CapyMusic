import 'package:flutter/cupertino.dart';
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
    // Trả về PlayingPage và truyền vào các thông tin cần thiết.
    return PlayingPage(songs: songs, playingSong: playingSong);
  }
}

/// Trang hiển thị giao diện chi tiết khi đang phát một bài hát.
class PlayingPage extends StatefulWidget {
  const PlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  /// Đối tượng bài hát đang phát.
  final Song playingSong;
  /// Danh sách bài hát phục vụ cho tính năng chuyển bài.
  final List<Song> songs;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

/// Lớp quản lý trạng thái cho PlayingPage.
class _PlayingPageState extends State<PlayingPage> {
  @override
  Widget build(BuildContext context) {
    // Sử dụng Scaffold theo phong cách Cupertino (iOS) làm khung cho trang.
    return CupertinoPageScaffold(
      // Thanh tiêu đề phía trên cùng.
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Đang phát"), // Tiêu đề chính giữa thanh điều hướng.
        // Nút chức năng bên phải (thường dùng cho menu thêm).
        trailing: IconButton(
          onPressed: () {
            // TODO: Xử lý khi nhấn vào nút thêm (ba chấm).
          },
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      // Phần nội dung chính của trang.
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị tên album của bài hát hiện tại.
              Text(widget.playingSong.album),
              const SizedBox(height: 16), // Khoảng cách giữa các thành phần.
              const Text('_ ___ _'), // Một dòng ngăn cách trang trí.
              const SizedBox(height: 48), // Khoảng cách phía dưới.
            ],
          ),
        ),
      ),
    );
  }
}
