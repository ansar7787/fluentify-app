import 'package:flutter/material.dart';
import '../../domain/entities/word_match_level_entity.dart';

class WordMatchGamePage extends StatelessWidget {
  final WordMatchLevelEntity level;
  final VoidCallback onLevelComplete;

  const WordMatchGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: Center(child: Text("Word Match Game - Level ${level.level}")),
    );
  }
}
