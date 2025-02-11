import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});
  static int sessionHighScore = 0;

  static Future<File> get _localFile async {
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/game_2048_high_score.txt');
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
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  static const int gridSize = 4;
  List<List<int>> grid = List.generate(
    gridSize,
    (_) => List.generate(gridSize, (_) => 0),
  );
  int score = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _loadSavedHighScore();
    addNewTile();
    addNewTile();
  }

  Future<void> _loadSavedHighScore() async {
    final savedHighScore = await Game2048.loadHighScore();
    setState(() {
      Game2048.sessionHighScore = savedHighScore;
    });
  }

  void updateHighScore() {
    if (score > Game2048.sessionHighScore) {
      setState(() {
        Game2048.sessionHighScore = score;
      });
      Game2048.saveHighScore(score); // Save immediately when there's a new high score
    }
  }

  void addNewTile() {
    List<List<int>> emptyPositions = [];
    int maxTile = 0;
    
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          emptyPositions.add([i, j]);
        }
        maxTile = max(maxTile, grid[i][j]);
      }
    }

    if (emptyPositions.isEmpty) return;

    final random = Random();
    final position = emptyPositions[random.nextInt(emptyPositions.length)];
    
    int newValue;
    if (maxTile >= 512) {
      double rand = random.nextDouble();
      if (rand < 0.6) {
        newValue = 2;
      } else if (rand < 0.9){
        newValue = 4;
      }
      else{
        newValue = 8;
      }
    } else if (maxTile >= 256) {
      newValue = random.nextDouble() < 0.7 ? 2 : 4;
    } else {
      newValue = random.nextDouble() < 0.9 ? 2 : 4;
    }
    
    setState(() {
      grid[position[0]][position[1]] = newValue;
    });
  }

  bool canMove() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) return true;
        if (j < gridSize - 1 && grid[i][j] == grid[i][j + 1]) return true;
        if (i < gridSize - 1 && grid[i][j] == grid[i + 1][j]) return true;
      }
    }
    return false;
  }

  void move(DragEndDetails details) {
    if (gameOver) return;

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;
    const minVelocity = 150.0; // Minimum velocity threshold
    bool moved = false;
    
    if (dx.abs() < minVelocity && dy.abs() < minVelocity) {
      return; // Ignore small movements
    }
    
    if (dx.abs() > dy.abs() * 1.5) { // Horizontal movement must be significantly larger
      if (dx > 0) {
        moved = moveRight();
      } else {
        moved = moveLeft();
      }
    } else if (dy.abs() > dx.abs() * 1.5) { // Vertical movement must be significantly larger
      if (dy > 0) {
        moved = moveDown();
      } else {
        moved = moveUp();
      }
    }

    if (moved) {
      addNewTile();
      updateHighScore();
      
      if (!canMove()) {
        gameOver = true;
        _showGameOverDialog();
      }
      setState(() {});
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: $score'),
              Text('High Score: ${Game2048.sessionHighScore}'),
              if (score >= Game2048.sessionHighScore && score > 0) 
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
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  bool moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = grid[i].where((x) => x != 0).toList();
      List<int> newRow = List.filled(gridSize, 0);
      int writeIndex = 0;
      
      for (int readIndex = 0; readIndex < row.length; readIndex++) {
        if (readIndex + 1 < row.length && row[readIndex] == row[readIndex + 1]) {
          newRow[writeIndex] = row[readIndex] * 2;
          score += row[readIndex] * 2;
          readIndex++;
          moved = true;
        } else {
          newRow[writeIndex] = row[readIndex];
        }
        writeIndex++;
      }
      
      if (!listEquals(grid[i], newRow)) {
        moved = true;
        grid[i] = newRow;
      }
    }
    return moved;
  }

  bool moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      grid[i] = grid[i].reversed.toList();
    }
    moved = moveLeft();
    for (int i = 0; i < gridSize; i++) {
      grid[i] = grid[i].reversed.toList();
    }
    return moved;
  }

  bool moveUp() {
    bool moved = false;
    List<List<int>> transposed = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => grid[j][i]),
    );
    grid = transposed;
    moved = moveLeft();
    transposed = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => grid[j][i]),
    );
    grid = transposed;
    return moved;
  }

  bool moveDown() {
    bool moved = false;
    List<List<int>> transposed = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => grid[j][i]),
    );
    grid = transposed;
    moved = moveRight();
    transposed = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => grid[j][i]),
    );
    grid = transposed;
    return moved;
  }

  void resetGame() {
    setState(() {
      grid = List.generate(
        gridSize,
        (_) => List.generate(gridSize, (_) => 0),
      );
      score = 0;
      gameOver = false;
      _loadSavedHighScore(); // Reload the high score when resetting
      addNewTile();
      addNewTile();
    });
  }

  Color getTileColor(int value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      switch (value) {
        case 2: return const Color(0xFF3D3A33);
        case 4: return const Color(0xFF3D3B2E);
        case 8: return const Color(0xFF996233);
        case 16: return const Color(0xFF9E4A23);
        case 32: return const Color(0xFFA13B1E);
        case 64: return const Color(0xFFA12F15);
        case 128: return const Color(0xFF987219);
        case 256: return const Color(0xFF986B15);
        case 512: return const Color(0xFF98640D);
        case 1024: return const Color(0xFF985D0A);
        case 2048: return const Color(0xFF985607);
        default: return const Color(0xFF2F2C25);
      }
    } else {
      switch (value) {
        case 2: return const Color(0xFFEEE4DA);
        case 4: return const Color(0xFFEDE0C8);
        case 8: return const Color(0xFFF2B179);
        case 16: return const Color(0xFFF59563);
        case 32: return const Color(0xFFF67C5F);
        case 64: return const Color(0xFFF65E3B);
        case 128: return const Color(0xFFEDCF72);
        case 256: return const Color(0xFFEDCC61);
        case 512: return const Color(0xFFEDC850);
        case 1024: return const Color(0xFFEDC53F);
        case 2048: return const Color(0xFFEDC22E);
        default: return const Color(0xFFCDC1B4);
      }
    }
  }

  Color getNumberColor(int value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return value <= 4 ? const Color(0xFFBBB5AD) : Colors.white;
    }
    return value <= 4 ? const Color(0xFF776E65) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final maxWidth = shortestSide * 0.92;
    final tileSize = (maxWidth - (gridSize * 8)) / gridSize;
    final fontSize = tileSize * 0.4;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1B16) : const Color(0xFFFAF8EF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('2048',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF776E65)
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1B16) : const Color(0xFFFAF8EF),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : const Color(0xFF776E65)
            ),
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
            icon: Icon(
              Icons.exit_to_app,
              color: isDark ? Colors.white : const Color(0xFF776E65)
            ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3C3830) : const Color(0xFFBBADA0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onPanEnd: move,
                onPanCancel: () {},
                onPanDown: (_) {},
                child: Container(
                  width: maxWidth,
                  height: maxWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3C3830) : const Color(0xFFBBADA0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: List.generate(
                      gridSize,
                      (i) => Expanded(
                        child: Row(
                          children: List.generate(
                            gridSize,
                            (j) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: getTileColor(grid[i][j]),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    grid[i][j] == 0 ? '' : grid[i][j].toString(),
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: getNumberColor(grid[i][j]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    'Swipe to move tiles',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF776E65),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3C3830) : const Color(0xFFBBADA0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Best: ${Game2048.sessionHighScore}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}