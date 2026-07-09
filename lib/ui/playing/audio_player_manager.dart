import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

/// Lớp quản lý trình phát nhạc, xử lý việc phát nhạc và theo dõi tiến trình bài hát.
class AudioPlayerManager {
  /// Khởi tạo manager với URL của bài hát cần phát.
  AudioPlayerManager({required this.songUrl});

  /// Đối tượng AudioPlayer để điều khiển việc phát nhạc.
  final player = AudioPlayer();
  
  /// Stream cung cấp thông tin về trạng thái thời gian của bài hát (vị trí, đệm, tổng thời gian).
  Stream<DurationState>? durationState;
  
  /// URL của bài hát hiện tại.
  String songUrl;

  /// Khởi tạo và thiết lập các luồng dữ liệu cho trình phát.
  void init() {
    // Kết hợp thông tin vị trí hiện tại và các sự kiện trình phát để tạo Stream DurationState.
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    // Thiết lập URL cho trình phát để bắt đầu tải nhạc.
    player.setUrl(songUrl);
  }

  /// Cập nhật URL mới cho bài hát và khởi tạo lại trình phát.
  void updateSongUrl(String url) {
    songUrl = url;
    init();
  }

  /// Giải phóng tài nguyên của trình phát nhạc khi không còn sử dụng.
  void dispose() {
    player.dispose();
  }
}

/// Lớp chứa thông tin về tiến trình phát, vùng đệm và tổng thời gian của bài hát.
class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  /// Thời gian hiện tại bài hát đã phát.
  final Duration progress;
  /// Thời gian nhạc đã được tải vào vùng đệm.
  final Duration buffered;
  /// Tổng thời lượng của bài hát.
  final Duration? total;
}
