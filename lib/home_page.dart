
import 'package:amica/RoomPage.dart';
import 'package:amica/SchedulePage.dart';
import 'package:amica/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'dashboard_page.dart';
import 'exercise_page.dart';
import 'health_monitoring_page.dart';
import 'settings_page.dart';
// Import the SchedulePage

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _children = [
    DashboardPage(),
    ExercisePage(),
    Chatscreen(),
    SchedulePage(), // Add the SchedulePage
    SettingsPage(),
    RoomPage()
    // Add the RoomPage
  ];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: _children,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.black, // Background color for the nav bar
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_children.length, (index) {
              return GestureDetector(
                onTap: () => onTabTapped(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForIndex(index),
                        color: _currentIndex == index
                            ? hextStringToColor("5E61F4")
                            : Colors.grey,
                      ),
                      Text(
                        _getLabelForIndex(index),
                        style: TextStyle(
                          color: _currentIndex == index
                              ? hextStringToColor("5E61F4")
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.fitness_center;
      case 2:
        return Icons.healing_sharp;
      case 3:
        return Icons.schedule_rounded;
      case 4:
        return Icons.settings;
      case 5:
        return Icons.meeting_room_outlined;
      default:
        return Icons.dashboard;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Exercises';
      case 2:
        return 'Health';
      case 3:
        return 'Schedule';
      case 4:
        return 'Settings';
      case 5:
        return 'ROOM';
      default:
        return 'Dashboard';
    }
  }

  Color hextStringToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
