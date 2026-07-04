/// Lớp đại diện cho một bài hát trong ứng dụng.
class Song {
  /// Khởi tạo một đối tượng Song với đầy đủ thông tin bắt buộc.
  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
  });

  /// Factory method để tạo đối tượng Song từ dữ liệu JSON (Map).
  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      source: map['source'],
      image: map['image'],
      duration: map['duration'],
    );
  }

  /// Mã định danh duy nhất của bài hát.
  String id;

  /// Tiêu đề bài hát.
  String title;

  /// Tên album chứa bài hát.
  String album;

  /// Tên nghệ sĩ trình bày.
  String artist;

  /// Đường dẫn hoặc URL nguồn của file nhạc.
  String source;

  /// Đường dẫn hoặc URL hình ảnh minh họa (cover art).
  String image;

  /// Thời lượng bài hát (thường tính bằng giây).
  int duration;

  /// Ghi đè toán tử so sánh để kiểm tra hai bài hát có cùng ID hay không.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  /// Sử dụng mã băm dựa trên ID của bài hát.
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration}';
  }
}
