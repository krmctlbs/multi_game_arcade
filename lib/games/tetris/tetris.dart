import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multi_game_arcade/games/tetris/piece.dart';
import 'package:multi_game_arcade/games/tetris/pixel.dart';
import 'package:multi_game_arcade/games/tetris/values.dart';

List<List<Tetromino?>> gameBoard = List.generate(
    colLength,
        (i) => List.generate(
          rowLength,
            (j) => null,
        ),
);
class Tetris extends StatefulWidget {
  const Tetris({super.key});
  static int sessionHighScore = 0;

  static Future<File> get _localFile async {
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/tetris_high_score.txt');
    if (!await file.exists()) {
      await file.create();
      await file.writeAsString('0');
    }
    return file;
  }

  static Future<void> saveHighScore(int score) async {
    try {
      final file = await _localFile;
      await file.writeAsString(score.toString());
      debugPrint('Saved high score: $score to ${file.path}');
    } catch (e) {
      debugPrint('Error saving high score: $e');
    }
  }

  static Future<int> loadHighScore() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final score = int.tryParse(contents.trim()) ?? 0;
        sessionHighScore = score;
        debugPrint('Loaded high score: $score from ${file.path}');
        return score;
      }
    } catch (e) {
      debugPrint('Error loading high score: $e');
    }
    return 0;
  }

  @override
  State<Tetris> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  //Current Tetris piece
  Piece currentPiece = Piece(type: Tetromino.L);
  //current score
  int currentScore = 0;
  // game over or not ???
  bool gameOver = false;
  // Timer for game loop
  Timer? _gameLoopTimer;

  @override
  void initState() {
    super.initState();
    //load high score and start game when app starts
    _loadSavedHighScore();
    startGame();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedHighScore() async {
    final savedHighScore = await Tetris.loadHighScore();
    setState(() {
      Tetris.sessionHighScore = savedHighScore;
    });
  }

  void updateHighScore() {
    if (currentScore > Tetris.sessionHighScore) {
      setState(() {
        Tetris.sessionHighScore = currentScore;
      });
      Tetris.saveHighScore(currentScore);
    }
  }

  void startGame() {
    currentPiece.initializePiece();
    //frame refresh rate
    Duration frameRate = const Duration(
        milliseconds: 333); //use this ms for level if ms goes down it will be harder to control
    gameLoop(frameRate);
  }

  //gameloop
  void gameLoop(Duration frameRate) {
    _gameLoopTimer?.cancel(); // Cancel any existing timer
    _gameLoopTimer = Timer.periodic(
        frameRate,
            (timer) {
          setState(() {
            //clear lines
            clearLines();
            //check for landing
            checkLanding();
            //check game status
            if(gameOver == true){
              timer.cancel();
              showGameOverDialog();
            }
            //move current piece down
            currentPiece.movePiece(Direction.down);
          });
        }
    );
  }

  //game over message
  void showGameOverDialog(){
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $currentScore'),
            Text('High Score: ${Tetris.sessionHighScore}'),
            if (currentScore >= Tetris.sessionHighScore && currentScore > 0) 
              const Text(
                'New High Score!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text('Play Again'),
          )
        ]
      )
    );
  }

  //reset game
  void resetGame(){
    _gameLoopTimer?.cancel(); // Cancel existing timer
    //clear game board
    gameBoard = List.generate(
      colLength,
          (i) => List.generate(
        rowLength,
            (j) => null,
      ),
    );

    //new game
    gameOver = false;
    currentScore = 0;
    //reload high score when resetting
    _loadSavedHighScore();
    //create a new piece
    createNewPiece();
    //start game again
    startGame();
  }
  //physics- collision detection for future position
  //true for coll false for no coll

  bool checkCollision(Direction direction) {
    //loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate the row and column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      //adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      //check if the piece is out of bounds (too low, right or left)
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      //check if the cell is already occupied by a landed piece
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    //no collision detected
    return false;
  }
  void createNewPiece(){
    //create a random object to generate random tetromino types
    Random rand = Random();

    //create a new piece with random type
    Tetromino randomType = Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if(isGameOver()){
      gameOver = true;
    }
  }
  void checkLanding() {
    //if going down occupied
    if (checkCollision(Direction.down)) {
      //mark the position as occupied on the game board
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = (currentPiece.position[i] % rowLength);
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      //once landing create a new piece
      createNewPiece();
    }
  }

  //CONTROL FUNCTIONS move left, move right, rotate
  void moveLeft(){
    //check if it is a valid move
    if(!checkCollision(Direction.left)){
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight(){
    //check if it is a valid move
    if(!checkCollision(Direction.right)){
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece(){
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  //clear lines
  void clearLines(){
    //step 1 loop trough each row of the board from bottom to top
    for(int row = colLength -1; row >= 0; row--){
      //step 2 init a variable to track if the row is full
      bool isRowFull = true;
      //step 3 check if the row full ( all cols are full w pieces)
      for(int col = 0; col < rowLength; col++){
        //if there is a empty col isrowfull = false / break the loop
        if(gameBoard[row][col] == null){
          isRowFull = false;
          break;
        }
      }
      //step 4 row is full then clear it and collapse above to down anyway
      if(isRowFull){
        //step 5 move all row above to the cleared row
        for(int r = row; r > 0; r--){
          //copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r-1]);
        }

        //step 6 set the top row to empty
        gameBoard[0] =  List.generate(row, (index) => null);

        // step 7 increase the score and update high score
        currentScore++;
        updateHighScore();
      }
    }
  }

  //game over! method
  bool isGameOver(){
    for(int col = 0; col < rowLength; col++){
      if(gameBoard[0][col] != null){
        return true;
      }
    }
    //otherwise
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text('Tetris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Reset Game'),
                    content: const Text('Are you sure you want to start a new game?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          resetGame();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                },
              );
            },
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
                      onPressed: () {
                        resetGame(); // Reset game
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
        children: [
          //GAME GRID
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                //get row and col of each index
                int row = (index / rowLength).floor();
                int col = (index % rowLength);
                //current piece
                if (currentPiece.position.contains(index)) {
                  return Pixel(
                    color: currentPiece.color,
                  );
                }
                //landed pieces
                else if(gameBoard[row][col] != null){
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(color: tetrominoColors[tetrominoType]);
                }
                //blank pixel
                else {
                  return Pixel(color: Colors.grey[900]);
                }
              }
            ),
          ),

          // Score and High Score display
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Score: $currentScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Best: ${Tetris.sessionHighScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          //GAME CONTROLS
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              //left
              IconButton(
                  onPressed: moveLeft,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_ios)
              ),
              //rotate
              IconButton(
                  onPressed: rotatePiece,
                  color: Colors.white,
                  icon: const Icon(Icons.rotate_right)
              ),
              //right
              IconButton(
                  onPressed: moveRight,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_forward_ios)
              ),
            ],),
          )
        ],
      ),
    );
  }
}
