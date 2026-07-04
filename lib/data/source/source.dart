import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/song.dart';
import 'package:http/http.dart' as http;

/// Giao diện định nghĩa các phương thức để lấy dữ liệu bài hát.
abstract interface class DataSource {
  /// Tải danh sách bài hát. Trả về [List<Song>] nếu thành công, hoặc null.
  Future<List<Song>?> loadData();
}

/// Lớp thực thi lấy dữ liệu từ nguồn từ xa (Remote API).
class RemoteDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async{
    const url = 'https://thantrieu.com/resources/braniumapis/songs.json';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    
    // Kiểm tra nếu phản hồi từ server là thành công (200 OK)
    if(response.statusCode == 200) {
      // Giải mã dữ liệu byte sang chuỗi UTF-8
      final bodyContent = utf8.decode(response.bodyBytes);
      // Chuyển đổi chuỗi JSON thành Map
      var songWrapper = jsonDecode(bodyContent) as Map;
      // Lấy danh sách bài hát từ key 'songs'
      var songList = songWrapper['songs'] as List;
      // Chuyển đổi từng phần tử trong danh sách sang đối tượng Song
      List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
      return songs;
    } else {
      // Trả về null nếu có lỗi xảy ra
      return null;
    }
  }

}

/// Lớp thực thi lấy dữ liệu từ nguồn nội bộ (Local database hoặc file).
class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    // Đọc nội dung file JSON từ thư mục assets của ứng dụng.
    final String response = await rootBundle.loadString('assets/songs.json');
    // Chuyển đổi chuỗi JSON vừa đọc được thành một Map.
    final jsonBody = jsonDecode(response) as Map;
    // Lấy danh sách bài hát từ key 'songs'.
    final songList = jsonBody['songs'] as  List;
    // Ánh xạ từng phần tử trong danh sách sang đối tượng Song.
    List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
    return songs;
  }
}
