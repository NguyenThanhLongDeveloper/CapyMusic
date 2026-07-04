import '../model/song.dart';
import '../source/source.dart';

/// Giao diện định nghĩa các phương thức cho Repository, 
/// đóng vai trò là điểm truy cập duy nhất cho dữ liệu trong ứng dụng.
abstract interface class Repository {
  /// Tải danh sách bài hát từ tất cả các nguồn có sẵn.
  Future<List<Song>?> loadData();
}

/// Lớp thực thi mặc định của Repository.
/// Quản lý việc ưu tiên lấy dữ liệu từ Remote trước, nếu lỗi sẽ lấy từ Local.
class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();


  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    
    // Tải dữ liệu từ nguồn từ xa (Remote)
    final remoteSongs = await _remoteDataSource.loadData();
    
    if (remoteSongs == null) {
      // Nếu Remote không có dữ liệu, thử tải từ Local
      final localSongs = await _localDataSource.loadData();
      if (localSongs != null) {
        songs.addAll(localSongs);
      }
    } else {
      // Nếu có dữ liệu từ Remote, sử dụng danh sách này
      songs.addAll(remoteSongs);
    }
    
    return songs;
  }
}
