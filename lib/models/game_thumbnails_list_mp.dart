import 'package:flutter/material.dart';
import '../games/tictactoe/game_tictactoe_mp.dart';
import '../games/tictactoe/room_manager.dart';
import 'game_thumbnails_mp.dart';
import '../services/db/user_manager.dart';

class GameThumbnailsListMp extends StatelessWidget {
  const GameThumbnailsListMp({super.key});

  Future<void> navigateToGamePage(BuildContext context, String roomId, String gameId) async {
    final playerId = await UserManager().getPlayerId();
    
    switch (gameId) {
      case 'tictactoe':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameTicTacToeMultiplayer(
              gameId: gameId,
              playerId: playerId,
              roomId: roomId,
            ),
          ),
        );
        break;
      default:
        debugPrint("Game not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomManager = RoomManager();

    return Center(
      child: SizedBox(
        height: 350,
        child: FutureBuilder<String>(
          future: UserManager().getPlayerId(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final playerId = snapshot.data!;
            
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 100),
                GameThumbnailsMp(
                  title: 'Tic-Tac-Toe',
                  imageUrl: 'lib/assets/xox.png',
                  gameId: 'tictactoe',
                  playerId: playerId,
                  roomManager: roomManager,
                  onNavigate: (roomCode) async {
                    await navigateToGamePage(context, roomCode, 'tictactoe');
                  },
                ),

                const SizedBox(width: 10),

              ],
            );
          },
        ),
      ),
    );
  }
}
