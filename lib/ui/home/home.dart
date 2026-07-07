import 'package:capy_music/ui/discovery/discovery.dart';
import 'package:capy_music/ui/home/viewmodel.dart';
import 'package:capy_music/ui/settings/settings.dart';
import 'package:capy_music/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../playing/playing.dart';

/// Widget chính của ứng dụng Capy Music.
/// Thiết lập MaterialApp, cấu hình theme và trang khởi đầu.
class CapyMusic extends StatelessWidget {
  const CapyMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capy Music',
      theme: ThemeData(
        // Thiết lập tông màu chính dựa trên màu tím đậm (deepPurple).
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Sử dụng Material Design 3.
      ),
      home: const MusicHomePage(),
    );
  }
}

/// Trang chủ của ứng dụng, sử dụng cấu trúc Tab bar để điều hướng giữa các màn hình.
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  // Danh sách các màn hình (Tab) tương ứng với từng mục điều hướng trên TabBar.
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Kết hợp Cupertino Scaffold để tạo giao diện kiểu iOS cho thanh điều hướng trên cùng và Tab bar dưới cùng.
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Capy Music')),
      child: CupertinoTabScaffold(
        // Thanh điều hướng (Bottom Navigation Bar) ở dưới cùng của màn hình.
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        // Hàm xây dựng nội dung cho tab hiện tại dựa trên chỉ số index được chọn.
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

/// Widget bọc (wrapper) cho tab Trang chủ, dùng để định nghĩa lớp HomeTab riêng biệt.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

/// Màn hình hiển thị danh sách bài hát, xử lý việc tải dữ liệu từ ViewModel và hiển thị lên UI.
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = []; // Danh sách các bài hát được lưu trữ tại đây sau khi tải về.
  late CapyMusicViewModel _viewModel; // ViewModel quản lý việc lấy dữ liệu bài hát.

  @override
  void initState() {
    _viewModel = CapyMusicViewModel(); // Khởi tạo ViewModel.
    _viewModel.loadSongs(); // Bắt đầu quá trình tải danh sách bài hát.
    observeData(); // Thiết lập lắng nghe sự thay đổi dữ liệu từ stream.
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.songStream.close(); // Đảm bảo đóng StreamController khi widget bị hủy để tránh rò rỉ bộ nhớ.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Scaffold của Material để hiển thị nội dung chính.
    return Scaffold(body: getBody());
  }

  /// Hàm quyết định hiển thị widget nào dựa trên trạng thái của dữ liệu (đang tải hay đã có dữ liệu).
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  /// Trả về biểu tượng vòng xoay đang tải (Loading indicator).
  Widget getProgressBar() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Xây dựng một danh sách bài hát có đường kẻ ngăn cách bằng ListView.separated.
  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position); // Xây dựng giao diện cho từng mục bài hát.
      },
      separatorBuilder: (context, index) {
        // Đường kẻ ngang để ngăn cách giữa hai bài hát liên tiếp.
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true, // Cho phép ListView chỉ chiếm không gian cần thiết.
    );
  }

  /// Tạo một widget đại diện cho một hàng bài hát.
  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: songs[index],);
  }

  /// Đăng ký lắng nghe dữ liệu từ stream của ViewModel và cập nhật giao diện khi có danh sách bài hát mới.
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  /// Hàm dùng để hiển thị một Bottom Sheet khi người dùng nhấn vào nút chức năng.
  void showBottomSheet() {
    // TODO: Triển khai giao diện Bottom Sheet tại đây.
  }

  /// Chuyển hướng người dùng sang màn hình đang phát nhạc (Playing).
  void navigate(Song song) {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context){
          return Playing(
            songs : songs,
            playingSong: song
          );
        }),
    );
  }
}

/// Widget thành phần hiển thị chi tiết thông tin của một bài hát (Item trong danh sách).
class _SongItemSection extends StatelessWidget {
  const _SongItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent; // Tham chiếu đến State của HomeTabPage để gọi các hàm điều hướng.
  final Song song; // Dữ liệu của bài hát hiện tại.

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8
      ),
      // Hiển thị ảnh bìa bài hát với hiệu ứng tải ảnh mượt mà (FadeInImage).
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img.png', // Ảnh hiển thị tạm thời trong khi tải.
          image: song.image, // Đường dẫn URL ảnh thực tế từ mạng.
          width: 48,
          height: 48,
          // Hiển thị ảnh mặc định nếu xảy ra lỗi trong quá trình tải ảnh từ mạng.
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/img.png', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title), // Tiêu đề của bài hát.
      subtitle: Text(song.artist), // Tên của nghệ sĩ biểu diễn.
      // Nút hiển thị thêm các tùy chọn (biểu tượng ba chấm ngang).
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz), 
        onPressed: () {
          parent.showBottomSheet(); // Gọi hàm hiển thị Bottom Sheet khi nhấn vào.
        },
      ),
      // Xử lý sự kiện khi người dùng nhấn vào toàn bộ vùng của bài hát.
      onTap: () {
        parent.navigate(song); // Chuyển sang màn hình phát nhạc.
      },
    );
  }
}
