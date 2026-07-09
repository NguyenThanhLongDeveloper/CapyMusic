import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
  late int _selectedItemIndex; // Chỉ số của bài hát hiện tại trong danh sách.
  late Song _song; // Đối tượng bài hát hiện tại đang được hiển thị.

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    // Khởi tạo AnimationController với thời gian hoàn thành một vòng xoay là 12 giây.
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    // Khởi tạo và chuẩn bị trình quản lý âm thanh.
    _audioPlayerManager = AudioPlayerManager(
      songUrl: _song.source,
    );
    _audioPlayerManager.init();
    
    // Lưu lại vị trí của bài hát hiện tại trong danh sách bài hát.
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  void dispose() {
    // Giải phóng bộ điều khiển ảnh khi widget bị hủy.
    _imageAnimationController.dispose();
    // Huỷ trình quản lý âm thanh để giải phóng tài nguyên.
    _audioPlayerManager.dispose();
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
              Text(_song.album),
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
                    image: _song.image,
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
                            _song.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _song.artist,
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

              // Vùng hiển thị các nút điều khiển nhạc.
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
    return SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MediaButtonControl(function: null, icon: Icons.shuffle, color: Colors.deepPurple, size: 24),
            MediaButtonControl(function: _setPreviousSong, icon: Icons.skip_previous, color: Colors.deepPurple, size: 36),
            _playButton(), // Nút Phát/Tạm dừng nhạc.
            MediaButtonControl(function: _setNextSong, icon: Icons.skip_next, color: Colors.deepPurple, size: 36),
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
          onSeek: _audioPlayerManager.player.seek, // Xử lý khi người dùng tua nhạc.
          barHeight: 5.0,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.grey.withOpacity(0.3),
          progressBarColor: Colors.green,
          bufferedBarColor:   Colors.grey.withOpacity(0.3),
          thumbGlowColor: Colors.black,
          thumbRadius: 10.0,
        );
      },
    );
  }

  /// Xây dựng nút điều khiển Phát/Tạm dừng dựa trên trạng thái hiện tại của trình phát nhạc.
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream, // Lắng nghe luồng trạng thái trình phát.
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState; // Trạng thái xử lý (loading, buffering, ready, completed).
        final playing = playState?.playing; // Có đang phát hay không.

        // Nếu đang tải hoặc đang đệm nhạc, hiển thị vòng xoay tiến trình.
        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } 
        // Nếu không đang phát nhạc, hiển thị nút Play.
        else if (playing != true) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.play(); // Gọi lệnh phát nhạc.
            }, 
            icon: Icons.play_arrow, 
            color: null, 
            size: 48
          );
        } 
        // Nếu đang phát và chưa hoàn thành, hiển thị nút Pause.
        else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause(); // Gọi lệnh tạm dừng.
            }, 
            icon: Icons.pause, 
            color: null, 
            size: 48
          );
        } 
        // Nếu đã hoàn thành bài hát, hiển thị nút Replay để phát lại từ đầu.
        else {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(Duration.zero); // Quay về thời điểm bắt đầu.
            }, 
            icon: Icons.replay, 
            color: null, 
            size: 48
          );
        }
      }
    );
  }

  /// Chuyển sang bài hát tiếp theo trong danh sách.
  void _setNextSong() {
    if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
      final nextSong = widget.songs[_selectedItemIndex];
      _audioPlayerManager.updateSongUrl(nextSong.source);
      setState(() {
        _song = nextSong;
      });
    }
  }

  /// Quay lại bài hát trước đó trong danh sách.
  void _setPreviousSong() {
    if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
      final previousSong = widget.songs[_selectedItemIndex];
      _audioPlayerManager.updateSongUrl(previousSong.source);
      setState(() {
        _song = previousSong;
      });
    }
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
