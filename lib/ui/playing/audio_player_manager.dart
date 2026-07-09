import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

/// Lớp quản lý trình phát nhạc, xử lý việc phát nhạc và theo dõi tiến trình bài hát.
/// Sử dụng mô hình Singleton để đảm bảo chỉ có một trình phát nhạc duy nhất trong toàn bộ ứng dụng.
class AudioPlayerManager {
  // Hàm khởi tạo riêng tư (private constructor) để ngăn tạo instance từ bên ngoài.
  AudioPlayerManager._internal();
  
  // Instance duy nhất của lớp AudioPlayerManager.
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  
  /// Factory constructor trả về instance duy nhất của manager.
  factory AudioPlayerManager() => _instance;

  /// Đối tượng AudioPlayer từ thư viện just_audio để điều khiển việc phát nhạc thực tế.
  final player = AudioPlayer();
  
  /// Stream cung cấp thông tin về trạng thái thời gian của bài hát (vị trí hiện tại, vùng đệm, tổng thời gian).
  Stream<DurationState>? durationState;
  
  /// URL của bài hát hiện tại đang được xử lý.
  String songUrl = "";

  /// Chuẩn bị trình phát nhạc bằng cách thiết lập URL và khởi tạo luồng dữ liệu tiến trình.
  /// [isNewSong]: Nếu là true, trình phát sẽ tải URL bài hát mới.
  void prepare({bool isNewSong = false}) {
    // Sử dụng Rx.combineLatest2 để kết hợp hai luồng dữ liệu từ just_audio:
    // 1. Vị trí phát nhạc hiện tại (positionStream).
    // 2. Các sự kiện trình phát như trạng thái đệm và tổng thời lượng (playbackEventStream).
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position, // Thời gian bài hát đã phát qua.
        buffered: playbackEvent.bufferedPosition, // Thời gian nhạc đã tải vào bộ đệm.
        total: playbackEvent.duration, // Tổng thời lượng của bài hát.
      ),
    );
    
    // Nếu đây là bài hát mới, chúng ta yêu cầu AudioPlayer tải nguồn nhạc từ URL.
    if (isNewSong) {
      player.setUrl(songUrl);
    }
  }

  /// Cập nhật URL bài hát mới cho manager và thực hiện nạp lại bài hát.
  void updateSongUrl(String url) {
    songUrl = url;
    prepare(isNewSong: true); // Truyền true để AudioPlayer thực hiện setUrl nạp bài mới.
  }

  /// Giải phóng tài nguyên của trình phát nhạc khi không còn sử dụng để tránh rò rỉ bộ nhớ.
  void dispose() {
    player.dispose();
  }
}

/// Lớp dữ liệu chứa thông tin về tiến trình phát, vùng đệm và tổng thời gian của bài hát.
class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  /// Thời gian hiện tại bài hát đã phát (mili giây/giây).
  final Duration progress;
  /// Thời gian nhạc đã được tải vào vùng đệm (để hiển thị phần đã load trên thanh progress).
  final Duration buffered;
  /// Tổng thời lượng của bài hát (có thể null nếu chưa tải xong thông tin).
  final Duration? total;
}
