import 'package:flutter/material.dart';
import 'package:sevis_lakay/data/Item.dart' as rowCategory;

import 'package:sevis_lakay/views/favorites/favoritesScreen.dart';
import 'package:sevis_lakay/views/home/home_page.dart';
import 'package:sevis_lakay/views/map/mapscreen.dart';
import 'package:sevis_lakay/views/profile/profilescreen.dart';
import 'package:sevis_lakay/views/search/search.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigation();
}

class _BottomNavigation extends State<BottomNavigation> {
  int _currentIndex = 0;

  List<Widget> pages = [
    HomePage(),
    SearchScreen(selectedType: ''),
    const Mapscreen(),
    const FavoritePage(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        selectedFontSize: 15,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
