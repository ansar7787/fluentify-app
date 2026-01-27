import 'package:flutter/material.dart';
import '../../domain/entities/dictation_level_entity.dart';

class DictationGamePage extends StatelessWidget {
  final DictationLevelEntity level;
  final VoidCallback onLevelComplete;

  const DictationGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: Center(child: Text("Dictation Game - Level ${level.level}")),
    );
  }
}
