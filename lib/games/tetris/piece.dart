import 'package:flutter/cupertino.dart';
import 'package:multi_game_arcade/games/tetris/tetris.dart';
import 'package:multi_game_arcade/games/tetris/values.dart';

class Piece{
  Tetromino type;
  Piece({required this.type,});
  List<int> position = [];
  //color of the tetris piece
  Color get color{
    return tetrominoColors[type] ??
        const Color(0XFFFFFFFF);
  }
  void initializePiece(){
    switch(type){
      case Tetromino.L:
        position = [
          -26,
          -16,
          -6,
          -5,
        ];
        break;
      case Tetromino.J:
        position = [
          -25,
          -15,
          -5,
          -6,
        ];
        break;
      case Tetromino.I:
        position = [
          -4,
          -5,
          -6,
          -7,
        ];
        break;
      case Tetromino.O:
        position = [
          -15,
          -16,
          -5,
          -6,
        ];
        break;
      case Tetromino.S:
        position = [
          -15,
          -14,
          -6,
          -5,
        ];
        break;
      case Tetromino.Z:
        position = [
          -17,
          -16,
          -6,
          -5,
        ];
        break;
      case Tetromino.T:
        position = [
          -26,
          -16,
          -6,
          -15,
        ];
        break;
      default:
    }
  }


  void movePiece(Direction direction){
    switch(direction){
      case Direction.down:
        for(int i = 0; i <position.length; i++){
          position[i] += rowLength;
        }
      break;
      case Direction.left:
        for(int i = 0; i <position.length; i++){
          position[i] -= 1;
        }
        break;
      case Direction.right:
        for(int i = 0; i <position.length; i++){
          position[i] += 1;
        }
        break;
    default:
    }
  }
  //rotate piece
int rotationState = 1;
  //new position
  //ROTATE METHOD GENTLEMEN
void rotatePiece(){
  List<int> newPosition = [];
//rotate piece based on it's type
  switch(type){
    case Tetromino.L:
      switch(rotationState){
        case 0:

          //get the new position
          newPosition = [
            position[1] - rowLength,
            position[1],
            position[1] + rowLength,
            position[1] + rowLength + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
      break;
        case 1:

        //get the new position
          newPosition = [
            position[1] - 1,
            position[1],
            position[1] + 1,
            position[1] + rowLength - 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 2:

        //get the new position
          newPosition = [
            position[1] + rowLength,
            position[1],
            position[1] - rowLength,
            position[1] - rowLength - 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 3:

        //get the new position
          newPosition = [
            position[1] - rowLength + 1,
            position[1],
            position[1] + 1,
            position[1] - 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
      }
      break;

    case Tetromino.J:
      switch(rotationState){
        case 0:

        //get the new position
          newPosition = [
            position[1] - rowLength,
            position[1],
            position[1] + rowLength,
            position[1] + rowLength - 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 1:

        //get the new position
          newPosition = [
            position[1] - rowLength - 1,
            position[1],
            position[1] - 1,
            position[1] + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 2:

        //get the new position
          newPosition = [
            position[1] + rowLength,
            position[1],
            position[1] - rowLength,
            position[1] - rowLength + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 3:

        //get the new position
          newPosition = [
            position[1] + 1,
            position[1],
            position[1] - 1,
            position[1] + rowLength + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
      }
      break;

    case Tetromino.I:
      switch(rotationState){
        case 0:

        //get the new position
          newPosition = [
            position[1] -1,
            position[1],
            position[1] + 1,
            position[1] + 2,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 1:

        //get the new position
          newPosition = [
            position[1] - rowLength,
            position[1],
            position[1] + rowLength,
            position[1] + 2 * rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 2:

        //get the new position
          newPosition = [
            position[1] + 1,
            position[1],
            position[1] - 1,
            position[1] - 2,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 3:

        //get the new position
          newPosition = [
            position[1] + rowLength,
            position[1],
            position[1] - rowLength,
            position[1] - 2 * rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
      }
      break;

    case Tetromino.O:
      // rotation does not needed
      break;

    case Tetromino.S:
      switch(rotationState){
        case 0:

        //get the new position
          newPosition = [
            position[1],
            position[1] + 1,
            position[1] + rowLength - 1,
            position[1] + rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 1:

        //get the new position
          newPosition = [
            position[0] - rowLength,
            position[0],
            position[0] + 1,
            position[0] + rowLength + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 2:

        //get the new position
          newPosition = [
            position[1],
            position[1] + 1,
            position[1] + rowLength -1 ,
            position[1] + rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 3:

        //get the new position
          newPosition = [
            position[0] - rowLength,
            position[0],
            position[0] + 1,
            position[0] + rowLength + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
      }
      break;

    case Tetromino.Z:
      switch(rotationState){
        case 0:

        //get the new position
          newPosition = [
            position[0] + rowLength - 2,
            position[1],
            position[2] + rowLength - 1,
            position[3] + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 1:

        //get the new position
          newPosition = [
            position[0] - rowLength + 2,
            position[1],
            position[2] - rowLength + 1,
            position[3] - 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 2:

        //get the new position
          newPosition = [
            position[0] + rowLength - 2,
            position[1],
            position[2] + rowLength - 1,
            position[3] + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 3:

        //get the new position
          newPosition = [
            position[0] - rowLength + 2,
            position[1],
            position[2] - rowLength + 1,
            position[3] - 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
      }
      break;

    case Tetromino.T:
      switch(rotationState){
        case 0:

        //get the new position
          newPosition = [
            position[2] - rowLength,
            position[2],
            position[2] + 1,
            position[2] + rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 1:

        //get the new position
          newPosition = [
            position[1] - 1,
            position[1],
            position[1] + 1,
            position[1] + rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 2:

        //get the new position
          newPosition = [
            position[1] - rowLength,
            position[1] - 1,
            position[1],
            position[1] + rowLength,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
        case 3:

        //get the new position
          newPosition = [
            position[2] - rowLength,
            position[2] - 1,
            position[2],
            position[2] + 1,
          ];
          //check that if the new position is valid move or not before the new assignment of positions
          if(isPiecePositionValid(newPosition)){
            //update the position
            position = newPosition;
            // update rotation state
            rotationState = (rotationState + 1) % 4;
          }
          break;
      }
      break;

    default: debugPrint("some error occurred while rotating");
  }

}
//check if the position is valid for rotating

bool isPositionValid(int position){
  //get the row and col of position
  int row = (position / rowLength).floor();
  int col = (position % rowLength);

  //if the position is taken return false
  if(row < 0 || col < 0 ||gameBoard[row][col] != null) {
    return false;
  }
  // otherwise return true
  else{
    return true;
  }
}
  //check if piece is valid position
bool isPiecePositionValid(List<int> piecePosition){
  bool firstColOccupied = false;
  bool lastColOccupied = false;

  for(int pos in piecePosition){
    //return false if any position is already taken
    if(!isPositionValid(pos)){
      return false;
    }
    //get the col of the position

    int col = pos % rowLength;

    //check if the first and last col is occupied
    if(col == 0){
      firstColOccupied = true;
    }
    if(col == rowLength - 1){
      lastColOccupied = true;
    }
  }
  //if there i a piece in first and last col, its going trough the wall
  return !(firstColOccupied && lastColOccupied);
}
}