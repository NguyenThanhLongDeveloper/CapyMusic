import 'dart:async';

import 'package:capy_music/data/repository/repository.dart';

import '../../data/model/song.dart';

/// ViewModel chịu trách nhiệm xử lý logic nghiệp vụ cho màn hình Home.
/// Nó kết nối giữa Repository và Giao diện (UI).
class CapyMusicViewModel {
  /// StreamController để quản lý dòng dữ liệu của danh sách bài hát.
  /// UI sẽ lắng nghe (listen) stream này để cập nhật giao diện khi có dữ liệu mới.
  StreamController<List<Song>> songStream = StreamController();

  /// Phương thức thực hiện việc tải danh sách bài hát từ Repository.
  void loadSongs() {
    // Khởi tạo repository để truy cập dữ liệu.
    final repository = DefaultRepository();
    
    // Gọi phương thức loadData từ repository.
    // Khi dữ liệu được tải xong (then), chúng ta đẩy kết quả vào stream.
    repository.loadData().then((value) {
      if (value != null) {
        songStream.add(value);
      }
    });
  }
}
