import 'package:flutter/material.dart';
import '../../domain/entities/typing_level_entity.dart';

class TypingGamePage extends StatelessWidget {
  final TypingLevelEntity level;
  final VoidCallback onLevelComplete;

  const TypingGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: Center(child: Text("Typing Game - Level ${level.level}")),
    );
  }
}
