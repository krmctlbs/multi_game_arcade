import 'package:flutter/material.dart';
import '../games/tictactoe/room_manager.dart';

class GameThumbnailsMp extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String gameId; // Game ID for the specific game (e.g., 'tictactoe')
  final String playerId; // Player ID for the player
  final RoomManager roomManager; // RoomManager instance to handle room operations
  final Function(String) onNavigate; // Callback function for navigation

  const GameThumbnailsMp({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.gameId,
    required this.playerId,
    required this.roomManager,
    required this.onNavigate, // Pass navigation function
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueGrey, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        margin: const EdgeInsets.all(4.0),
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(imageUrl, height: 200, width: 200),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String roomCodeInput = ''; // Room code için değişken
                        return AlertDialog(
                          title: const Text('Create or Join Room'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min, // Dialog boyutunu küçült
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    String roomCode = await roomManager.createRoom(
                                      gameId: gameId,
                                      playerId: playerId,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context); // Dialog'u kapat
                                      onNavigate(roomCode);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Create New Room'),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Enter Room Code',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => roomCodeInput = value,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  if (roomCodeInput.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter a room code')),
                                    );
                                    return;
                                  }
                                  try {
                                    await roomManager.joinRoom(
                                      gameId: gameId,
                                      roomCode: roomCodeInput,
                                      playerId: playerId,
                                      onRoomJoined: (joinedRoomCode) {
                                        Navigator.pop(context);
                                        onNavigate(joinedRoomCode);
                                      },
                                      onError: (error) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $error')),
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                                child: const Text('Join Room'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Play Multiplayer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
