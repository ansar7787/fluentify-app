abstract class GameContent {}

class WordMatchContent extends GameContent {
  final Map<String, String>
      pairs; // e.g., {'Happy': 'Joyful', 'Sad': 'Unhappy'}
  WordMatchContent({required this.pairs});
}

class GameLevel {
  final int number;
  final String description;
  final bool isLocked;
  final int stars;
  final GameContent content;

  GameLevel({
    required this.number,
    required this.description,
    this.isLocked = true,
    this.stars = 0,
    required this.content,
  });
}
