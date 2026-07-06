import 'dart:async';

import 'package:capy_music/data/repository/repository.dart';

import '../../data/model/song.dart';

/// ViewModel cho CapyMusic để quản lý luồng dữ liệu bài hát.
class CapyMusicViewModel {
  /// StreamController để truyền danh sách bài hát đến giao diện.
  StreamController<List<Song>> songStream = StreamController();

  /// Tải danh sách bài hát từ repository và đẩy vào stream.
  void loadSongs() {
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }
}
