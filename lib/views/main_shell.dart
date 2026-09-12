import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home/home_screen.dart';
import 'shorts/shorts_screen.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  final List<Widget>? screens;

  const MainShell({super.key, this.screens});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [];
  DateTime? _lastBackPressTime;

  late final List<Widget> _screens = widget.screens ??
      const [
        HomeScreen(),
        ShortsScreen(),
        BookmarksScreen(),
        ProfileScreen(),
      ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _tabHistory.remove(index);
      _tabHistory.add(_currentIndex);
      _currentIndex = index;
    });
  }

  void _handleBackPress() {
    // If not on Home tab, navigate back to previous tab or Home tab
    if (_currentIndex != 0) {
      setState(() {
        if (_tabHistory.isNotEmpty) {
          _currentIndex = _tabHistory.removeLast();
        } else {
          _currentIndex = 0;
        }
      });
      return;
    }

    // On Home tab: double back press to exit with friendly confirmation
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Press back again to exit'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: const Color(0xFF2C2825),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF16171A) : const Color(0xFFF7F6F3);
    const activeColor = Color(0xFFFF8C00);
    final inactiveColor = isDark ? Colors.white54 : Colors.black54;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBgColor,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 0.8,
              ),
            ),
          ),
          child: BottomNavigationBar(
            key: const Key('byline_bottom_nav'),
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBgColor,
            selectedItemColor: activeColor,
            unselectedItemColor: inactiveColor,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_outlined),
                activeIcon: Icon(Icons.newspaper, color: activeColor),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.subtitles_outlined),
                activeIcon: Icon(Icons.subtitles, color: activeColor),
                label: 'Byline Shorts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work, color: activeColor),
                label: 'Portfolio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stars_outlined),
                activeIcon: Icon(Icons.stars, color: activeColor),
                label: 'Premium',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
