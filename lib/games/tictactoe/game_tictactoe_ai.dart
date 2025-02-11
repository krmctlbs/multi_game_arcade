import 'package:flutter/material.dart';
import 'game_logic.dart';
import 'dart:math';

class GameTicTacToeAi extends StatefulWidget {
  const GameTicTacToeAi({super.key});

  @override
  GameTicTacToeAiState createState() => GameTicTacToeAiState();
}

class GameTicTacToeAiState extends State<GameTicTacToeAi> {
  final GameLogic gameLogic = GameLogic();

  void playerMove(int row, int col) {
    if (gameLogic.board[row][col].isNotEmpty || gameLogic.isGameOver) {
      return;
    }

    setState(() {
      gameLogic.board[row][col] = 'X';
      gameLogic.currentPlayer = 'O';
      
      String result = gameLogic.checkWinner();
      if (result.isNotEmpty) {
        gameLogic.winner = result;
        gameLogic.isGameOver = true;
        return;
      }
      
      // AI's turn
      if (!gameLogic.isGameOver) {
        aiMove();
      }
    });
  }

  void aiMove() {
    // Simple AI: randomly select an empty cell
    List<Point<int>> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (gameLogic.board[i][j].isEmpty) {
          emptyCells.add(Point(i, j));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final random = Random();
      final move = emptyCells[random.nextInt(emptyCells.length)];
      
      setState(() {
        gameLogic.board[move.x][move.y] = 'O';
        gameLogic.currentPlayer = 'X';
        
        String result = gameLogic.checkWinner();
        if (result.isNotEmpty) {
          gameLogic.winner = result;
          gameLogic.isGameOver = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tic Tac Toe - AI'),
        actions: [
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
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to menu
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              int row = index ~/ 3;
              int col = index % 3;
              return GestureDetector(
                onTap: () {
                  if (!gameLogic.isGameOver) {
                    playerMove(row, col);
                  }
                },
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
          if (gameLogic.winner.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                gameLogic.winner == 'Draw' 
                    ? "It's a Draw!" 
                    : '${gameLogic.winner} Wins!',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  gameLogic.resetBoard();
                });
              },
              child: const Text("Reset Game"),
            ),
          ),
        ],
      ),
    );
  }
}
