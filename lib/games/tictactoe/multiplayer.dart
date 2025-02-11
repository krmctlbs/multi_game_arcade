import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:multi_game_arcade/games/tictactoe/room_manager.dart';
enum RoomState {
  waiting,
  inProgress,
  completed,
  abandoned
}

class Multiplayer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RoomManager _roomManager = RoomManager();

  // Create a new game room in Firestore
  Future<String> createRoom(String gameId, String playerId) async {
    developer.log('Creating new room for game: $gameId, player: $playerId', name: 'Multiplayer');
    
    try {
      String roomCode = await _roomManager.createRoom(
        gameId: gameId,
        playerId: playerId,
      );
      
      developer.log('Room created with code: $roomCode', name: 'Multiplayer');
      return roomCode;
    } catch (e) {
      developer.log('Error creating room', name: 'Multiplayer', error: e.toString());
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }

  // Join an existing game room
  Future<void> joinRoom(String gameId, String roomId, String playerId) async {
    developer.log('Player $playerId joining room: $roomId', name: 'Multiplayer');
    
    try {
      var roomRef = _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomId);

      var roomSnapshot = await roomRef.get();
      if (!roomSnapshot.exists) {
        throw Exception('Room not found');
      }

      var data = roomSnapshot.data()!;
      
      // If player is reconnecting as player1
      if (data['player1'] == playerId) {
        // If room was abandoned due to this player's disconnect, restore it
        if (data['state'] == RoomState.abandoned.toString() && 
            data['disconnectedRole'] == 'player1') {
          await roomRef.update({
            'state': RoomState.inProgress.toString(),
            'disconnectedRole': null,
            'disconnectedPlayer': null,
            'disconnectedAt': null,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        developer.log('Player is already player1', name: 'Multiplayer');
        return;
      }

      if (data['player2'] != null && data['player2'] != playerId) {
        throw Exception('Room is full');
      }

      // If joining as player2
      await roomRef.update({
        'player2': playerId,
        'state': RoomState.inProgress.toString(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      developer.log('Player joined successfully', name: 'Multiplayer');
    } catch (e) {
      developer.log('Error joining room', name: 'Multiplayer', error: e.toString());
      throw Exception('Failed to join room: ${e.toString()}');
    }
  }

  // Update game state in Firestore
  Future<void> updateGame(
      String gameId, String roomId, List<List<String>> board, String turn) async {
    developer.log('Updating game state for room: $roomId', name: 'Multiplayer');
    
    try {
      // 2D board'u düz array'e çevir
      List<String> flatBoard = [];
      for (var row in board) {
        flatBoard.addAll(row);
      }

      var roomRef = _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomId);
          
      await roomRef.update({
        'board': flatBoard,
        'currentPlayer': turn,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      developer.log('Game state updated successfully. Current player: $turn', name: 'Multiplayer');
    } catch (e) {
      developer.log('Error updating game state', name: 'Multiplayer', error: e.toString());
      throw Exception('Failed to update game state: ${e.toString()}');
    }
  }

  // Set the winner and mark the game as completed
  Future<void> setWinner(String gameId, String roomId, String winner) async {
    var roomRef = _firestore
        .collection('games')
        .doc(gameId)
        .collection('rooms')
        .doc(roomId);
    await roomRef.update({
      'winner': winner,
      'state': 'completed',
    });
  }

  // Reset the game state for a specific room
  Future<void> resetGame(String gameId, String roomId) async {
    developer.log('Resetting game for room: $roomId', name: 'Multiplayer');
    
    try {
      var roomRef = _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomId);
          
      await roomRef.update({
        'board': List.filled(9, ''),
        'currentPlayer': 'X',
        'winner': null,
        'state': RoomState.inProgress.toString(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      developer.log('Game reset successfully', name: 'Multiplayer');
    } catch (e) {
      developer.log('Error resetting game', name: 'Multiplayer', error: e.toString());
      throw Exception('Failed to reset game: ${e.toString()}');
    }
  }

  // Listen to updates for a specific game room
  Stream<DocumentSnapshot> listenToRoom(String gameId, String roomId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('rooms')
        .doc(roomId)
        .snapshots();
  }

  // Add room state tracking
  Future<void> updateRoomState(String gameId, String roomId, RoomState state) async {
    var roomRef = _firestore
        .collection('games')
        .doc(gameId)
        .collection('rooms')
        .doc(roomId);
        
    await roomRef.update({
      'state': state.toString(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Add player disconnect handling
  Future<void> handlePlayerDisconnect(String gameId, String roomId, String playerId) async {
    developer.log('Handling disconnect for player: $playerId', name: 'Multiplayer');
    
    try {
      var roomRef = _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomId);
          
      // First get the room data to check players
      var roomData = await roomRef.get();
      if (!roomData.exists) return;
      
      var data = roomData.data()!;
      
      // If room is already abandoned or completed, don't update
      if (data['state'] == RoomState.abandoned.toString() || 
          data['state'] == RoomState.completed.toString()) {
        return;
      }
      
      String disconnectedRole = data['player1'] == playerId ? 'player1' : 'player2';
      
      await roomRef.update({
        'state': RoomState.abandoned.toString(),
        'disconnectedPlayer': playerId,
        'disconnectedRole': disconnectedRole,
        'disconnectedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      developer.log('Player disconnect recorded', name: 'Multiplayer');
    } catch (e) {
      developer.log('Error handling player disconnect', 
        name: 'Multiplayer', 
        error: e.toString());
      throw Exception('Failed to handle player disconnect: ${e.toString()}');
    }
  }
}
