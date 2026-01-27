import 'package:flutter/material.dart';
import '../../domain/entities/reading_level_entity.dart';

class ReadingGamePage extends StatelessWidget {
  final ReadingLevelEntity level;
  final VoidCallback onLevelComplete;

  const ReadingGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: Center(child: Text("Reading Game - Level ${level.level}")),
    );
  }
}
