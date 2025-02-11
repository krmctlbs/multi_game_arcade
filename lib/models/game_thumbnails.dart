import 'package:flutter/material.dart';
//improve comments
class GameThumbnails extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onPlay; // Function for the Play button

  const GameThumbnails({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueGrey, Colors.lightBlue], // Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0), // Match card corners
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        margin: const EdgeInsets.all(4.0),
        color: Colors.transparent, // Make the card transparent to show the gradient
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
                  color: Colors.white, // Enhanced text color for readability
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Even space between buttons
              children: [
                ElevatedButton(
                  onPressed: onPlay, // Link to play action
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    // Customize button styles for better visibility
                  ),
                  child: const Text(
                    'Play',
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
