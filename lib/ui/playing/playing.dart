import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

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
/// Sử dụng SingleTickerProviderStateMixin để hỗ trợ cho AnimationController.
class _PlayingPageState extends State<PlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _imageAnimationController; // Bộ điều khiển cho hiệu ứng xoay ảnh bìa.
  late AudioPlayerManager _audioPlayerManager; // Trình quản lý phát nhạc.

  @override
  void initState() {
    super.initState();
    // Khởi tạo AnimationController với thời gian hoàn thành một vòng xoay là 12 giây.
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    // Khởi tạo và chuẩn bị trình quản lý âm thanh.
    _audioPlayerManager = AudioPlayerManager(
      songUrl: widget.playingSong.source,
    );
    _audioPlayerManager.init();
  }

  @override
  void dispose() {
    // Giải phóng bộ điều khiển ảnh khi widget bị hủy.
    _imageAnimationController
        .dispose(); // Hủy bộ điều khiển khi widget bị hủy để giải phóng bộ nhớ.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng của màn hình thiết bị.
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64; // Khoảng cách lề trái phải tổng cộng.
    final radius =
        (screenWidth - delta) /
        2; // Tính toán bán kính để ảnh bìa có hình tròn.

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
              const SizedBox(height: 16),
              // Khoảng cách giữa các thành phần.
              const Text('_ ___ _'),
              // Một dòng ngăn cách trang trí.
              const SizedBox(height: 32),
              // Khoảng cách phía dưới.
              // Hiệu ứng xoay cho ảnh bìa bài hát.
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 1.0,
                ).animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  // Làm tròn ảnh bìa thành hình tròn.
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/img.png',
                    // Ảnh hiển thị tạm thời trong khi tải ảnh từ internet.
                    image: widget.playingSong.image,
                    // URL ảnh bìa bài hát.
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    // Xử lý khi không tải được ảnh từ URL.
                    imageErrorBuilder: (context, error, StackTrace) {
                      return Image.asset(
                        'assets/img.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),

              // Phần hiển thị tiêu đề bài hát, nghệ sĩ và các nút tương tác (Share, Favorite).
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 8),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Nút chia sẻ bài hát.
                      IconButton(
                        onPressed: () {
                          // TODO: Xử lý chia sẻ.
                        },
                        icon: const Icon(Icons.share_outlined),
                      ),
                      // Hiển thị tên bài hát và nghệ sĩ ở giữa.
                      Column(
                        children: [
                          Text(
                            widget.playingSong.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.playingSong.artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      // Nút thêm vào danh sách yêu thích.
                      IconButton(
                        onPressed: () {
                          // TODO: Xử lý yêu thích.
                        },
                        icon: const Icon(Icons.favorite_outline),
                      ),
                    ],
                  ),
                ),
              ),

              // Vùng hiển thị thanh tiến trình bài hát.
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 24,
                  right: 24,
                  bottom: 8,
                ),
                child: _progressBar(),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 24,
                  right: 24,
                ),
                child: _mediaButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng hàng các nút điều khiển nhạc (Shuffle, Previous, Play/Pause, Next, Repeat).
  Widget _mediaButton() {
    return const SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MediaButtonControl(function: null, icon: Icons.shuffle, color: Colors.deepPurple, size: 24),
            MediaButtonControl(function: null, icon: Icons.skip_previous, color: Colors.deepPurple, size: 36),
            MediaButtonControl(function: null, icon: Icons.play_arrow_sharp, color: Colors.deepPurple, size: 48),
            MediaButtonControl(function: null, icon: Icons.skip_next, color: Colors.deepPurple, size: 36),
            MediaButtonControl(function: null, icon: Icons.repeat, color: Colors.deepPurple, size: 24),

          ],
        )
    );
  }

  /// Xây dựng thanh tiến trình dựa trên trạng thái thời gian thực của trình phát nhạc.
  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      // Lắng nghe luồng dữ liệu tiến trình.
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        // Widget ProgressBar hiển thị tiến trình phát, vùng đệm và tổng thời gian.
        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
        );
      },
    );
  }
}

/// Một widget tùy chỉnh để hiển thị các nút điều khiển phương tiện với icon, màu sắc và kích thước tùy biến.
class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  /// Hàm xử lý sự kiện khi nút được nhấn.
  final void Function()? function;
  /// Biểu tượng của nút.
  final IconData icon;
  /// Kích thước của biểu tượng.
  final double? size;
  /// Màu sắc của biểu tượng.
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

/// Trạng thái của MediaButtonControl.
class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
