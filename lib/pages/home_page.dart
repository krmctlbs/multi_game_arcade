
import 'package:flutter/material.dart';
import 'package:multi_game_arcade/models/game_thumbnails_list_mp.dart';
import 'package:multi_game_arcade/pages/settings.dart';
import '../models/game_thumbnails_list.dart';
import '../models/my_bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPageContent() {
    switch (_selectedIndex) {
      case 0:
        return const Settings();
      case 1:
        return Column(
          children: const [
            Spacer(),
            GameThumbnailsList(), // Use extracted game thumbnails widget
            Spacer(),
          ],
        );
      case 2:
        return Column(
        children: const [
          Spacer(),
          GameThumbnailsListMp(), // Use extracted game thumbnails widget
          Spacer(),
        ],
        );
      default:
        return const Center(child: Text('Arcade App/ navigation error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: _getPageContent(),
      bottomNavigationBar: CustomBottomNavBar( // Use extracted bottom navbar widget
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
