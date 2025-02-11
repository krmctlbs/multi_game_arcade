import 'package:flutter/material.dart';
import 'package:multi_game_arcade/games/tetris/tetris.dart';
import 'package:multi_game_arcade/games/tictactoe/game_tictactoe_ai.dart';
import 'package:multi_game_arcade/games/twok48/game_2048.dart';
import '../models/game_thumbnails.dart';

class GameThumbnailsList extends StatelessWidget {
  const GameThumbnailsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 350, // Adjust height as needed
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 100),
            GameThumbnails(
              title: 'Tic-Tac-Toe',
              imageUrl: 'lib/assets/xox.png',
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameTicTacToeAi()),
                );
              },
            ),
            const SizedBox(width: 10),
            GameThumbnails(
              title: 'Tetris',
              imageUrl: 'lib/assets/tetris.png',
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tetris()),
                );
              },

            ),
            const SizedBox(width: 10),
            GameThumbnails(
              title: '2048',
              imageUrl: 'lib/assets/2048.png',
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Game2048()),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
