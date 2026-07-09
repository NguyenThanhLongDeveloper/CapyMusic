import 'dart:math';

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

  /// Danh sách tất cả các bài hát để có thể thực hiện tính năng chuyển bài (Next/Previous).
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    // Trả về PlayingPage và truyền vào các thông tin bài hát cần thiết.
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

  /// Đối tượng bài hát đang phát truyền từ widget cha.
  final Song playingSong;

  /// Danh sách bài hát phục vụ cho tính năng chuyển bài và phát ngẫu nhiên.
  final List<Song> songs;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

/// Lớp quản lý trạng thái cho PlayingPage.
/// Sử dụng SingleTickerProviderStateMixin để hỗ trợ cho việc tạo AnimationController xoay ảnh đĩa.
class _PlayingPageState extends State<PlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _imageAnimationController; // Bộ điều khiển cho hiệu ứng xoay tròn của ảnh bìa bài hát.
  late AudioPlayerManager _audioPlayerManager; // Trình quản lý điều khiển phát nhạc (Singleton).
  late int _selectedItemIndex; // Chỉ số của bài hát hiện tại trong danh sách để điều hướng bài tiếp/trước.
  late Song _song; // Đối tượng bài hát hiện tại đang được hiển thị trên giao diện.
  late double _currentAnimationPosition; // Lưu trữ vị trí tiến trình hoạt ảnh hiện tại khi tạm dừng để tiếp tục sau đó.
  late bool _isShuffle = false; // Trạng thái bật/tắt chế độ phát nhạc ngẫu nhiên.
  late LoopMode _loopMode = LoopMode.off; // Trạng thái chế độ lặp lại bài hát (Tắt, Lặp 1 bài, Lặp tất cả).

  @override
  void initState() {
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.playingSong;
    
    // Khởi tạo AnimationController với thời gian hoàn thành một vòng xoay (360 độ) là 12 giây.
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    // Khởi tạo trình quản lý âm thanh. 
    // Nếu bài hát mới khác với bài đang phát hiện tại, tiến hành cập nhật URL và chuẩn bị trình phát.
    _audioPlayerManager = AudioPlayerManager();
    if (_audioPlayerManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare();
    }
    
    // Lưu lại vị trí của bài hát hiện tại trong danh sách bài hát để biết bài tiếp theo/trước đó là gì.
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);

    // Đăng ký lắng nghe luồng trạng thái của trình phát nhạc.
    // Khi bài hát phát hết (completed), tự động gọi hàm chuyển bài tiếp theo.
    _audioPlayerManager.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _setNextSong();
      }
    });
  }

  @override
  void dispose() {
    // Giải phóng bộ điều khiển ảnh khi widget bị hủy để tránh rò rỉ tài nguyên.
    _imageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng của màn hình thiết bị để tính toán kích thước đĩa nhạc.
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64; // Tổng khoảng cách lề (trái 32 + phải 32).
    final radius =
        (screenWidth - delta) /
        2; // Tính toán bán kính để ảnh bìa luôn hiển thị ở giữa và có hình tròn hoàn hảo.

    // Sử dụng Scaffold theo phong cách Cupertino (iOS) làm khung giao diện cho trang.
    return CupertinoPageScaffold(
      // Thanh tiêu đề phía trên cùng của màn hình.
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Đang phát"), // Tiêu đề nằm ở giữa thanh điều hướng.
        // Nút chức năng bên phải (thường dùng cho menu tùy chọn thêm như lời bài hát, hẹn giờ...).
        trailing: IconButton(
          onPressed: () {
            // TODO: Xử lý hiển thị menu tùy chọn thêm khi nhấn vào nút ba chấm.
          },
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      // Sử dụng Material Scaffold làm body để hỗ trợ tốt hơn cho các widget Material Design.
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị tên album của bài hát hiện tại.
              Text(_song.album),
              const SizedBox(height: 16),
              // Một dòng ngăn cách trang trí đơn giản.
              const Text('_ ___ _'),
              const SizedBox(height: 32),
              
              // Widget thực hiện hiệu ứng xoay đĩa nhạc cho ảnh bìa.
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 1.0,
                ).animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  // Làm tròn ảnh bìa thành hình tròn.
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/img.png', // Ảnh hiển thị tạm thời trong khi tải từ internet.
                    image: _song.image, // URL ảnh bài hát thực tế.
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    // Hiển thị ảnh thay thế nếu không tải được ảnh từ URL (image error).
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

              // Khu vực hiển thị tiêu đề bài hát, tên nghệ sĩ và các nút Share/Favorite.
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 8),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Nút chia sẻ bài hát.
                      IconButton(
                        onPressed: () {
                          // TODO: Xử lý chức năng chia sẻ bài hát qua mạng xã hội.
                        },
                        icon: const Icon(Icons.share_outlined),
                      ),
                      // Hiển thị thông tin chính của bài hát ở trung tâm.
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
                      // Nút thêm bài hát vào danh sách yêu thích.
                      IconButton(
                        onPressed: () {
                          // TODO: Xử lý logic đánh dấu bài hát là yêu thích.
                        },
                        icon: const Icon(Icons.favorite_outline),
                      ),
                    ],
                  ),
                ),
              ),

              // Thanh tiến trình (ProgressBar) hiển thị thời gian phát và cho phép tua nhạc.
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 24,
                  right: 24,
                  bottom: 8,
                ),
                child: _progressBar(),
              ),

              // Khu vực chứa các nút điều khiển chính: Shuffle, Previous, Play/Pause, Next, Repeat.
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

  /// Xây dựng hàng chứa các nút điều khiển phương tiện.
  Widget _mediaButton() {
    return SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Nút bật/tắt chế độ phát nhạc ngẫu nhiên (Shuffle).
            MediaButtonControl(function: _setShuffle, icon: Icons.shuffle, color: _getShuffleColor(), size: 24),
            // Nút quay lại bài hát trước đó trong danh sách.
            MediaButtonControl(function: _setPreviousSong, icon: Icons.skip_previous, color: Colors.deepPurple, size: 36),
            // Nút chính Phát hoặc Tạm dừng nhạc.
            _playButton(),
            // Nút chuyển sang bài hát tiếp theo trong danh sách.
            MediaButtonControl(function: _setNextSong, icon: Icons.skip_next, color: Colors.deepPurple, size: 36),
            // Nút bật/tắt chế độ lặp lại bài hát (Repeat).
            MediaButtonControl(function: _setRepeat, icon: _getRepeatIcon(), color: _getRepeatColor(), size: 24),

          ],
        )
    );
  }

  /// Xây dựng thanh tiến trình bài hát, tự động cập nhật theo luồng dữ liệu thời gian thực từ trình phát.
  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero; // Thời gian đã phát.
        final buffered = durationState?.buffered ?? Duration.zero; // Thời gian đã load đệm.
        final total = durationState?.total ?? Duration.zero; // Tổng thời lượng bài hát.

        // Widget ProgressBar hiển thị trực quan tiến trình và cho phép người dùng tua nhạc (seek).
        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: _audioPlayerManager.player.seek, // Gọi hàm seek khi người dùng kéo thanh tiến trình.
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

  /// Xây dựng nút điều khiển Phát/Tạm dừng, thay đổi giao diện dựa trên trạng thái hiện tại của AudioPlayer.
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream, // Lắng nghe trạng thái (playing, loading, completed).
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState; // Trạng thái xử lý dữ liệu của player.
        final playing = playState?.playing; // Biến boolean xác định đang phát hay tạm dừng.

        // Nếu trình phát đang tải nhạc hoặc đang nạp bộ đệm, hiển thị vòng quay tải (loading).
        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
          _pauseRotationAnim(); // Tạm dừng hoạt ảnh xoay đĩa khi đang tải dữ liệu.
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } 
        // Nếu trình phát không đang chơi nhạc, hiển thị icon Play để người dùng kích hoạt.
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
        // Nếu đang phát nhạc và chưa kết thúc bài hát, hiển thị icon Pause để người dùng tạm dừng.
        else if (processingState != ProcessingState.completed) {
          _playRotationAnim(); // Bắt đầu chạy hoạt ảnh xoay đĩa nhạc khi đang phát.
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause(); // Gọi lệnh tạm dừng nhạc.
              _pauseRotationAnim(); // Tạm dừng hiệu ứng xoay đĩa.
            }, 
            icon: Icons.pause, 
            color: null, 
            size: 48
          );
        } 
        // Khi bài hát đã phát hết, hiển thị icon Replay để phát lại bài hát đó từ đầu.
        else {
          if (processingState == ProcessingState.completed) {
            _stopRotationAnim(); // Dừng xoay đĩa khi bài hát kết thúc.
            _resetRotationAnim(); // Đưa đĩa nhạc về vị trí bắt đầu.
          }
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(Duration.zero); // Tua bài hát về thời điểm 0:00.
              _resetRotationAnim();
              _playRotationAnim();
            }, 
            icon: Icons.replay, 
            color: null, 
            size: 48
          );
        }
      }
    );
  }

  /// Chuyển đổi trạng thái chế độ phát ngẫu nhiên (Shuffle).
  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  /// Lấy màu sắc cho icon Shuffle dựa trên trạng thái bật (màu tím) hay tắt (màu xám).
  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  /// Thay đổi chế độ lặp lại bài hát xoay vòng giữa: Tắt -> Lặp 1 bài -> Lặp tất cả -> Tắt.
  void _setRepeat() {
    setState(() {
      if (_loopMode == LoopMode.off) {
        _loopMode = LoopMode.one;
      } else if (_loopMode == LoopMode.one) {
        _loopMode = LoopMode.all;
      } else {
        _loopMode = LoopMode.off;
      }
      
      // Nếu là chế độ lặp một bài (LoopMode.one), cấu hình trực tiếp vào trình phát của just_audio.
      // Nếu không phải, chúng ta để trình phát ở chế độ bình thường và tự xử lý logic ở hàm chuyển bài.
      if (_loopMode == LoopMode.one) {
        _audioPlayerManager.player.setLoopMode(LoopMode.one);
      } else {
        _audioPlayerManager.player.setLoopMode(LoopMode.off);
      }
    });
  }

  /// Trả về biểu tượng (icon) phù hợp với chế độ lặp hiện tại.
  IconData _getRepeatIcon() {
    return _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat;
  }

  /// Lấy màu sắc cho icon Repeat dựa trên việc tính năng này có đang được bật hay không.
  Color? _getRepeatColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }

  /// Hàm xử lý logic chuyển sang bài hát tiếp theo.
  void _setNextSong() {
    if (_isShuffle) {
      // Nếu đang bật chế độ Shuffle, chọn ngẫu nhiên một chỉ số từ danh sách bài hát.
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      // Nếu không Shuffle, chuyển sang bài tiếp theo theo thứ tự danh sách.
      ++_selectedItemIndex;
    }  else if (_loopMode == LoopMode.all) {
      // Nếu đã ở cuối danh sách nhưng đang bật "Lặp lại tất cả", quay về bài đầu tiên.
      _selectedItemIndex = 0;
    } else {
      // Trường hợp cuối danh sách và không lặp lại: dừng lại và không làm gì thêm.
      return;
    }

    // Cập nhật đối tượng bài hát mới dựa trên chỉ số vừa xác định.
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source); // Cập nhật URL bài hát mới cho manager.
    _audioPlayerManager.player.play(); // Tự động phát nhạc sau khi đổi bài.
    _resetRotationAnim(); // Đặt lại hoạt ảnh xoay ảnh bìa về vị trí ban đầu cho bài mới.
    setState(() {
      _song = nextSong; // Cập nhật bài hát hiện tại để UI thay đổi tên, ảnh bài hát.
    });
  }

  /// Hàm xử lý logic quay lại bài hát trước đó.
  void _setPreviousSong() {
    if (_isShuffle) {
      // Nếu đang bật Shuffle, việc quay lại cũng sẽ chọn một bài ngẫu nhiên.
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      // Chuyển về bài hát đứng trước trong danh sách.
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all) {
      // Nếu đang ở bài đầu tiên và bật "Lặp lại tất cả", quay về bài cuối cùng của danh sách.
      _selectedItemIndex = widget.songs.length - 1;
    } else {
      // Nếu không ở cuối danh sách, chúng ta tua bài hiện tại về đầu (0:00).
      _audioPlayerManager.player.seek(Duration.zero);
      return;
    }

    // Cập nhật và phát bài hát vừa chọn.
    final previousSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(previousSong.source);
    _audioPlayerManager.player.play();
    _resetRotationAnim();
    setState(() {
      _song = previousSong;
    });
  }

  /// Kích hoạt hiệu ứng xoay cho ảnh bìa bài hát.
  void _playRotationAnim() {
    _imageAnimationController.forward(from: _currentAnimationPosition);
    _imageAnimationController.repeat(); // Hoạt ảnh xoay lặp đi lặp lại liên tục.
  }

  /// Tạm dừng hiệu ứng xoay đĩa và ghi nhớ vị trí hiện tại để có thể tiếp tục xoay từ đó.
  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimationController.value;
  }

  /// Dừng bộ điều khiển hoạt ảnh xoay ảnh bìa.
  void _stopRotationAnim() {
    _imageAnimationController.stop();
  }

  /// Đặt lại tiến trình hoạt ảnh xoay về giá trị 0.0 (vị trí ban đầu).
  void _resetRotationAnim() {
    _currentAnimationPosition = 0.0;
    _imageAnimationController.value = _currentAnimationPosition;
  }
}

/// Widget tùy chỉnh cho các nút điều khiển nhạc (Shuffle, Play, Next...).
class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  /// Hàm sẽ được gọi khi người dùng nhấn vào nút.
  final void Function()? function;
  /// Icon hiển thị trên nút.
  final IconData icon;
  /// Kích thước của biểu tượng nút.
  final double? size;
  /// Màu sắc của icon, nếu null sẽ dùng màu mặc định của ứng dụng.
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

/// Trạng thái của MediaButtonControl, quản lý việc hiển thị UI của nút.
class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function, // Gán sự kiện nhấn nút.
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
