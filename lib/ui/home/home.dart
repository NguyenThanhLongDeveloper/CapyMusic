import 'package:capy_music/ui/discovery/discovery.dart';
import 'package:capy_music/ui/home/viewmodel.dart';
import 'package:capy_music/ui/settings/settings.dart';
import 'package:capy_music/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';

/// Widget chính của ứng dụng Capy Music.
/// Thiết lập MaterialApp, theme và trang chủ đầu tiên.
class CapyMusic extends StatelessWidget {
  const CapyMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capy Music',
      debugShowCheckedModeBanner: false, // Tắt biểu tượng "Debug" ở góc màn hình.
      theme: ThemeData(
        // Thiết lập tông màu chính dựa trên màu tím đậm.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Sử dụng Material Design 3 mới nhất.
      ),
      home: const MusicHomePage(),
    );
  }
}

/// Trang chủ của ứng dụng, chứa thanh điều hướng phía dưới (Tab bar).
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  // Danh sách các tab (màn hình) sẽ hiển thị tương ứng với từng icon.
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Sử dụng giao diện kiểu Cupertino (iOS) cho trang chủ.
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Capy Music')),
      child: CupertinoTabScaffold(
        // Thanh điều hướng dưới cùng.
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        // Hàm xây dựng nội dung cho từng tab dựa trên chỉ mục (index).
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

/// Widget bọc ngoài cho tab "Home" để có thể chứa nội dung động.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

/// Màn hình hiển thị danh sách bài hát trong tab Home.
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = []; // Danh sách các bài hát sẽ hiển thị.
  late CapyMusicViewModel _viewModel; // ViewModel để xử lý logic lấy dữ liệu.

  @override
  void initState() {
    super.initState();
    _viewModel = CapyMusicViewModel();
    _viewModel.loadSongs(); // Yêu cầu ViewModel tải danh sách bài hát.
    observeData(); // Lắng nghe sự thay đổi dữ liệu từ ViewModel.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  /// Quyết định hiển thị Loading hoặc Danh sách bài hát dựa trên trạng thái dữ liệu.
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  /// Widget hiển thị vòng xoay tải dữ liệu.
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Xây dựng danh sách bài hát dạng ListView.
  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position); // Xây dựng từng hàng của danh sách.
      },
      separatorBuilder: (context, index) {
        // Đường kẻ phân cách giữa các bài hát.
        return const Divider(
          color: Colors.grey,
          thickness: 0.5,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  /// Xây dựng giao diện cho một dòng bài hát (tạm thời hiển thị text).
  Widget getRow(int index) {
    return ListTile(
      title: Text(songs[index].title),
      subtitle: Text(songs[index].artist),
      leading: const Icon(Icons.music_note),
    );
  }

  /// Lắng nghe Stream từ ViewModel để cập nhật UI khi có bài hát mới.
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}
