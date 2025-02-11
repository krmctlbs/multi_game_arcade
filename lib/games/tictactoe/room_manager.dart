import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:math';

class RoomManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a 6-digit room code
  String generateRoomCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12);
    developer.log('Generated room code: $random', name: 'RoomManager');
    return random;
  }

  // Create a new room in Firestore
  Future<String> createRoom({
    required String gameId,
    required String playerId,
  }) async {
    String roomCode = generateRoomCode();
    developer.log('Creating room with code: $roomCode for player: $playerId', name: 'RoomManager');

    try {
      // Check if room already exists
      var existingRoom = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomCode)
          .get();

      if (existingRoom.exists) {
        throw Exception('Room already exists, try again');
      }

      // Randomly decide starting player
      final random = Random();
      final startsWithX = random.nextBool();

      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomCode)
          .set({
        'gameId': gameId,
        'player1': playerId,
        'player2': null,
        'state': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'board': List.filled(9, ''),
        'currentPlayer': startsWithX ? 'X' : 'O',  // Set starting player based on random assignment
        'winner': null,
        'lastUpdated': FieldValue.serverTimestamp(),
        'roomCode': roomCode,
        'player1Symbol': startsWithX ? 'X' : 'O',  // Randomly assign symbols
        'player2Symbol': startsWithX ? 'O' : 'X',
      });

      developer.log('Room created successfully: $roomCode', name: 'RoomManager');
      return roomCode;
    } catch (e) {
      developer.log('Error creating room', name: 'RoomManager', error: e.toString());
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }

  // Add a method to verify room creation
  Future<bool> verifyRoomCreation(String gameId, String roomCode) async {
    try {
      var roomDoc = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomCode)
          .get();

      if (roomDoc.exists) {
        developer.log('Room verified: $roomCode', name: 'RoomManager');
        return true;
      } else {
        developer.log('Room verification failed: $roomCode', name: 'RoomManager');
        return false;
      }
    } catch (e) {
      developer.log('Error verifying room', name: 'RoomManager', error: e.toString());
      return false;
    }
  }

  // Join an existing room by room code
  Future<void> joinRoom({
    required String gameId,
    required String roomCode,
    required String playerId,
    required Function(String) onRoomJoined,
    required Function(String) onError,
  }) async {
    try {
      DocumentSnapshot roomSnapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomCode)
          .get();

      if (!roomSnapshot.exists) {
        throw Exception('Room not found.');
      }

      var data = roomSnapshot.data() as Map<String, dynamic>;

      // Check if the player is already player1
      if (data['player1'] == playerId) {
        developer.log('Player is already player1', name: 'RoomManager');
        onRoomJoined(roomCode);
        return;
      }

      // If player2 already exists and it's not this player, the room is full
      if (data['player2'] != null && data['player2'] != playerId) {
        throw Exception('Room is already full.');
      }

      // Join the room as player 2 only if not already player1
      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomCode)
          .update({
        'player2': playerId,
        'state': 'in_progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      developer.log('Player $playerId joined as player2', name: 'RoomManager');
      onRoomJoined(roomCode);
    } catch (e) {
      developer.log('Error joining room', name: 'RoomManager', error: e.toString());
      onError(e.toString());
    }
  }

  // Add room cleanup for abandoned games
  Future<void> cleanupAbandonedRooms() async {
    final threshold = DateTime.now().subtract(const Duration(minutes: 30));
    
    final abandonedRooms = await _firestore
        .collectionGroup('rooms')
        .where('state', isEqualTo: 'abandoned')
        .where('disconnectedAt', isLessThan: threshold)
        .get();
        
    for (var room in abandonedRooms.docs) {
      await room.reference.delete();
    }
  }

  // Add room validation
  Future<bool> isRoomValid(String gameId, String roomId) async {
    final roomDoc = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('rooms')
        .doc(roomId)
        .get();
        
    if (!roomDoc.exists) return false;
    
    final data = roomDoc.data()!;
    if (data['state'] == 'completed' || data['state'] == 'abandoned') {
      return false;
    }
    
    return true;
  }

  // Add new method for getting active rooms
  Future<List<Map<String, dynamic>>> getActiveRooms(String gameId) async {
    developer.log('Fetching active rooms for game: $gameId', name: 'RoomManager');
    
    try {
      var roomsSnapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .where('state', isEqualTo: 'waiting')
          .get();

      return roomsSnapshot.docs
          .map((doc) => {
                'roomId': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      developer.log('Error fetching active rooms', 
        name: 'RoomManager', 
        error: e.toString());
      return [];
    }
  }

  // Add method to check if player is in any active game
  Future<String?> getPlayerActiveRoom(String playerId) async {
    developer.log('Checking active rooms for player: $playerId', 
      name: 'RoomManager');
    
    try {
      var rooms = await _firestore
          .collectionGroup('rooms')
          .where('state', whereIn: ['waiting', 'in_progress'])
          .where(Filter.or(
            Filter('player1', isEqualTo: playerId),
            Filter('player2', isEqualTo: playerId),
          ))
          .get();

      if (rooms.docs.isNotEmpty) {
        developer.log('Found active room for player', name: 'RoomManager');
        return rooms.docs.first.id;
      }
      return null;
    } catch (e) {
      developer.log('Error checking player active rooms', 
        name: 'RoomManager', 
        error: e.toString());
      return null;
    }
  }

  // Add method for room status updates with proper error handling
  Future<void> updateRoomStatus(String gameId, String roomId, String status) async {
    developer.log('Updating room status - Game: $gameId, Room: $roomId, Status: $status', 
      name: 'RoomManager');
    
    try {
      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('rooms')
          .doc(roomId)
          .update({
        'state': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      developer.log('Room status updated successfully', name: 'RoomManager');
    } catch (e) {
      developer.log('Error updating room status', 
        name: 'RoomManager', 
        error: e.toString());
      throw Exception('Failed to update room status: ${e.toString()}');
    }
  }
}
