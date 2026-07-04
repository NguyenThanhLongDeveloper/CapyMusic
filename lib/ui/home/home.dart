import 'package:capy_music/ui/discovery/discovery.dart';
import 'package:capy_music/ui/settings/settings.dart';
import 'package:capy_music/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Widget chính của ứng dụng Capy Music.
/// Thiết lập MaterialApp, theme và trang chủ đầu tiên.
class CapyMusic extends StatelessWidget {
  const CapyMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capy Music',
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Capy Music'),
      ),
      child: CupertinoTabScaffold(
        // Thanh điều hướng dưới cùng.
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
        // Hàm xây dựng nội dung cho từng tab dựa trên chỉ mục (index).
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

/// Widget đại diện cho nội dung của tab "Home".
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
