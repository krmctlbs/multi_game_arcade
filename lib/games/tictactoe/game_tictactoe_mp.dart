import 'package:flutter/material.dart';
import 'multiplayer.dart';
import 'game_logic.dart'; // Assuming your provided logic is in game_logic.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:multi_game_arcade/games/tictactoe/room_manager.dart';

class GameTicTacToeMultiplayer extends StatefulWidget {
  final String gameId;
  final String roomId;
  final String playerId;

  const GameTicTacToeMultiplayer({
    super.key,
    required this.gameId,
    required this.roomId,
    required this.playerId,
  });

  @override
  State<GameTicTacToeMultiplayer> createState() =>
      _GameTicTacToeMultiplayerState();
}

class _GameTicTacToeMultiplayerState extends State<GameTicTacToeMultiplayer> {
  final Multiplayer multiplayer = Multiplayer();
  final GameLogic gameLogic = GameLogic();
  final RoomManager roomManager = RoomManager();
  bool isMyTurn = false;
  String? mySymbol;
  Map<String, dynamic>? gameData;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  @override
  void dispose() {
    if (mounted) {
      _handlePlayerLeaving();
    }
    super.dispose();
  }

  Future<void> _initializeRoom() async {
    developer.log('Initializing room...', name: 'TicTacToe');
    try {
      // Verify room exists
      bool isValid = await roomManager.isRoomValid(widget.gameId, widget.roomId);
      if (!isValid) {
        developer.log('Invalid room, creating new room', name: 'TicTacToe');
        // Create new room if invalid
        String newRoomId = await roomManager.createRoom(
          gameId: widget.gameId,
          playerId: widget.playerId,
        );
        developer.log('New room created: $newRoomId', name: 'TicTacToe');
      }

      await _fetchInitialGameData();
      _setupGameListener();
    } catch (e) {
      developer.log('Error initializing room', name: 'TicTacToe', error: e.toString());
    }
  }

  Future<void> _fetchInitialGameData() async {
    developer.log('Fetching initial game data', name: 'TicTacToe');
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .collection('rooms')
          .doc(widget.roomId)
          .get();

      if (snapshot.exists) {
        setState(() {
          gameData = snapshot.data();
          _initializeGame();
        });
        developer.log('Game data fetched: ${gameData.toString()}', name: 'TicTacToe');
      } else {
        developer.log('Room not found', name: 'TicTacToe', error: 'No data exists for this room');
      }
    } catch (e) {
      developer.log('Error fetching game data', name: 'TicTacToe', error: e.toString());
    }
  }

  void _initializeGame() {
    if (gameData == null) {
      developer.log('Game data is null during initialization', name: 'TicTacToe');
      return;
    }
    
    // Determine player symbol based on player order
    if (widget.playerId == gameData!['player1']) {
      mySymbol = 'X';
      developer.log('Player initialized as X (player1)', name: 'TicTacToe');
    } else if (widget.playerId == gameData!['player2']) {
      mySymbol = 'O';
      developer.log('Player initialized as O (player2)', name: 'TicTacToe');
    } else {
      developer.log('Player ID not matching any player in the room', 
        name: 'TicTacToe', 
        error: 'Invalid player ID');
      return;
    }
    
    isMyTurn = mySymbol == gameLogic.currentPlayer;
    developer.log('Game initialized - Player Symbol: $mySymbol, IsMyTurn: $isMyTurn', 
      name: 'TicTacToe');
  }

  void handleMove(int row, int col) async {
    if (!isMyTurn || gameLogic.isGameOver) {
      developer.log('Move rejected - Not your turn or game is over', name: 'TicTacToe');
      return;
    }

    if (gameLogic.board[row][col].isNotEmpty) {
      developer.log('Cell already occupied', name: 'TicTacToe');
      return;
    }

    developer.log('Making move at row: $row, col: $col', name: 'TicTacToe');
    
    try {
      gameLogic.board[row][col] = mySymbol!;
      gameLogic.currentPlayer = mySymbol == 'X' ? 'O' : 'X';
      
      String winner = gameLogic.checkWinner();
      bool isGameOver = winner.isNotEmpty;
      
      await multiplayer.updateGame(
        widget.gameId,
        widget.roomId,
        gameLogic.board,
        isGameOver ? '' : gameLogic.currentPlayer,
      );

      if (isGameOver) {
        developer.log('Winner found: $winner', name: 'TicTacToe');
        await multiplayer.setWinner(widget.gameId, widget.roomId, winner);
        setState(() {
          gameLogic.winner = winner;
          gameLogic.isGameOver = true;
        });
      }
    } catch (e) {
      developer.log('Error making move', name: 'TicTacToe', error: e.toString());
    }
  }

  void resetGame() async {
    try {
      await multiplayer.resetGame(widget.gameId, widget.roomId);
      setState(() {
        gameLogic.resetBoard();
        gameLogic.isGameOver = false;
        gameLogic.winner = '';
        isMyTurn = mySymbol == 'X'; // X always starts
      });
      developer.log('Game reset successfully', name: 'TicTacToe');
    } catch (e) {
      developer.log('Error resetting game', name: 'TicTacToe', error: e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting game: $e')),
        );
      }
    }
  }

  Future<void> _handlePlayerLeaving() async {
    try {
      developer.log('Player ${widget.playerId} leaving game', name: 'TicTacToe');
      await multiplayer.handlePlayerDisconnect(
        widget.gameId,
        widget.roomId,
        widget.playerId,
      );
    } catch (e) {
      developer.log('Error handling player leaving', 
        name: 'TicTacToe', 
        error: e.toString());
    }
  }

  void _setupGameListener() {
    multiplayer.listenToRoom(widget.gameId, widget.roomId).listen(
      (snapshot) {
        if (!snapshot.exists) {
          developer.log('Room no longer exists', name: 'TicTacToe');
          if (mounted) {
            _showDisconnectDialog('Room no longer exists');
          }
          return;
        }

        setState(() {
          gameData = snapshot.data() as Map<String, dynamic>;
          if (gameData != null) {
            // Check for disconnected player first
            if (gameData!['state'] == 'abandoned') {
              String? disconnectedPlayer = gameData!['disconnectedPlayer'];
              if (disconnectedPlayer != null && disconnectedPlayer != widget.playerId) {
                _showDisconnectDialog('Your opponent has left the game');
                return;
              }
            }

            // Update board state
            List<dynamic> flatBoard = gameData!['board'];
            gameLogic.board = List.generate(
              3,
              (i) => List.generate(
                3,
                (j) => flatBoard[i * 3 + j].toString(),
              ),
            );
            
            // Update game state
            gameLogic.currentPlayer = gameData!['currentPlayer'] ?? 'X';
            
            // Update winner and game over state
            if (gameData!['winner'] != null) {
              gameLogic.winner = gameData!['winner'].toString();
              gameLogic.isGameOver = true;
            } else {
              gameLogic.winner = '';
              gameLogic.isGameOver = false;
            }
            
            // Update player symbol if needed
            if (mySymbol == null) {
              if (widget.playerId == gameData!['player1']) {
                mySymbol = 'X';
              } else if (widget.playerId == gameData!['player2']) {
                mySymbol = 'O';
              }
            }
            
            isMyTurn = mySymbol == gameLogic.currentPlayer;
            
            developer.log('''
Game state updated:
Board: ${gameLogic.board}
Current Player: ${gameLogic.currentPlayer}
Winner: ${gameLogic.winner}
Game Over: ${gameLogic.isGameOver}
Game State: ${gameData!['state']}
My Symbol: $mySymbol
Is My Turn: $isMyTurn
''', name: 'TicTacToe');
          }
        });
      },
      onError: (error) {
        developer.log('Error listening to room updates', 
          name: 'TicTacToe', 
          error: error.toString());
      },
    );
  }

  void _showDisconnectDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Game Ended'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to menu
              },
              child: const Text('Return to Menu'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe - Multiplayer'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                gameLogic.isGameOver 
                    ? (gameLogic.winner == 'Draw' 
                        ? "It's a Draw!" 
                        : "${gameLogic.winner} Wins!")
                    : (isMyTurn ? 'Your Turn' : 'Opponent\'s Turn'),
                style: TextStyle(
                  color: gameLogic.isGameOver 
                      ? Colors.orange 
                      : (isMyTurn ? Colors.green : Colors.red),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Leave Game?'),
                  content: const Text('Are you sure you want to leave the game?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await multiplayer.handlePlayerDisconnect(
                          widget.gameId, 
                          widget.roomId, 
                          widget.playerId
                        );
                        if (mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Return to menu
                        }
                      },
                      child: const Text('Leave', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: gameData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Room ID display
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.room, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Room Code: ${widget.roomId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Player info
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'You are ${mySymbol ?? "..."} ',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Game board
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      int row = index ~/ 3;
                      int col = index % 3;
                      return GestureDetector(
                        onTap: () => handleMove(row, col),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: gameLogic.board[row][col] == 'X'
                                ? Colors.red[100]
                                : (gameLogic.board[row][col] == 'O'
                                ? Colors.blue[100]
                                : Colors.white),
                          ),
                          child: Center(
                            child: Text(
                              gameLogic.board[row][col],
                              style: TextStyle(
                                fontSize: 48,
                                color: gameLogic.board[row][col] == 'X'
                                    ? Colors.red
                                    : (gameLogic.board[row][col] == 'O'
                                    ? Colors.blue
                                    : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Game status and reset button
                  if (gameLogic.isGameOver)
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            gameLogic.winner == 'Draw'
                                ? 'It\'s a Draw!'
                                : '${gameLogic.winner} Wins!',
                            style: const TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: resetGame,
                            icon: const Icon(Icons.replay),
                            label: const Text('Play Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, 
                                vertical: 12
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Waiting for opponent message
                  if (gameData!['player2'] == null)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Waiting for opponent to join...',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (gameData?['state'] == RoomState.abandoned.toString())
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            gameData?['disconnectedRole'] == 'player1' 
                                ? 'Player 1 has disconnected'
                                : 'Player 2 has disconnected',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (gameData?['disconnectedAt'] != null)
                            Text(
                              'Game abandoned at ${(gameData?['disconnectedAt'] as Timestamp?)?.toDate().toString().split('.')[0] ?? 'Unknown time'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
