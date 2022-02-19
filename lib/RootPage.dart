import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/Statistics.dart';
import 'Home.dart';

class RootPage extends StatefulWidget {
  RootPageState createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Home(),
    Statistics(),
  ];

  void onTabClick(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.where_to_vote_outlined), label: "打卡"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "统计"),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF90CAF9),
        unselectedItemColor: Colors.black26,
        currentIndex: _currentIndex,
        onTap: onTabClick,
      ),
    );
  }
}
