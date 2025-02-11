class GameLogic {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  String winner = '';
  bool isGameOver = false;

  String checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != '' &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return board[i][0];
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != '' &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return board[0][i];
      }
    }

    // Check diagonals
    if (board[0][0] != '' &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }
    if (board[0][2] != '' &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }

    // Check for draw
    bool isDraw = true;
    for (var row in board) {
      for (var cell in row) {
        if (cell == '') {
          isDraw = false;
          break;
        }
      }
    }
    return isDraw ? 'Draw' : '';
  }

  void resetBoard() {
    board = List.generate(3, (_) => List.filled(3, ''));
    currentPlayer = 'X';
    winner = '';
    isGameOver = false;
  }
}
