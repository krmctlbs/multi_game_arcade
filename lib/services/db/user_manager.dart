import 'package:firebase_auth/firebase_auth.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;

  String? _playerId;

  UserManager._internal();

  /// Get the current player's ID
  Future<String> getPlayerId() async {
    if (_playerId != null) {
      return _playerId!;
    }

    // Check if Firebase Authentication is available
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Use Firebase user ID if logged in
      _playerId = firebaseUser.uid;
    } else {
      // Generate a new guest ID for non-authenticated users

    }

    return _playerId!;
  }

  /// Reset the player ID (useful for logging out or clearing data)
  void resetPlayerId() {
    _playerId = null;
  }
}
