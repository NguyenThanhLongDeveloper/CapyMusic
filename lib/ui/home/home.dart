import 'package:capy_music/ui/discovery/discovery.dart';
import 'package:capy_music/ui/home/viewmodel.dart';
import 'package:capy_music/ui/settings/settings.dart';
import 'package:capy_music/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';

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

/// Trang chủ của ứng dụng, sử dụng cấu trúc Tab bar để điều hướng.
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  // Danh sách các màn hình (Tab) tương ứng với từng mục điều hướng.
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Kết hợp Cupertino Scaffold để tạo giao diện kiểu iOS cho thanh điều hướng.
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Capy Music')),
      child: CupertinoTabScaffold(
        // Thanh điều hướng (Bottom Navigation Bar) ở dưới cùng.
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
        // Hàm xây dựng nội dung cho tab hiện tại dựa trên index.
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

/// Widget bọc (wrapper) cho tab Trang chủ.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

/// Màn hình hiển thị danh sách bài hát, xử lý việc tải và hiển thị dữ liệu.
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = []; // Lưu trữ danh sách bài hát nhận được từ ViewModel.
  late CapyMusicViewModel _viewModel; // Khai báo ViewModel.

  @override
  void initState() {
    _viewModel = CapyMusicViewModel(); // Khởi tạo ViewModel.
    _viewModel.loadSongs(); // Gọi hàm tải danh sách bài hát.
    observeData(); // Đăng ký lắng nghe dữ liệu mới.
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.songStream.close(); // Đóng stream để tránh rò rỉ bộ nhớ.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getBody());
  }

  /// Hàm trả về widget nội dung chính (Loading hoặc ListView).
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  /// Hiển thị biểu tượng đang tải dữ liệu.
  Widget getProgressBar() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Xây dựng ListView để hiển thị danh sách bài hát có đường kẻ phân cách.
  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position); // Trả về giao diện cho từng hàng.
      },
      separatorBuilder: (context, index) {
        // Đường kẻ ngăn cách giữa các bài hát.
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  /// Tạo widget cho từng dòng bài hát bằng cách gọi _songItemSection.
  Widget getRow(int index) {
    return _songItemSection(parent: this, song: songs[index],);
  }

  /// Lắng nghe stream từ ViewModel và cập nhật UI khi có dữ liệu mới.
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}

/// Widget hiển thị thông tin chi tiết của một bài hát (Item trong danh sách).
class _songItemSection extends StatelessWidget {
  const _songItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8
      ),
      // Ảnh minh họa bài hát được bo góc.
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img.png', // Ảnh hiển thị khi đang tải.
          image: song.image, // URL ảnh bài hát.
          width: 48,
          height: 48,
          // Xử lý lỗi nếu không tải được ảnh từ mạng.
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/img.png', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title), // Tiêu đề bài hát.
      subtitle: Text(song.artist), // Tên nghệ sĩ.
      // Nút chức năng thêm (ba chấm).
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz), 
        onPressed: () {},
      ),
    );
  }
}
